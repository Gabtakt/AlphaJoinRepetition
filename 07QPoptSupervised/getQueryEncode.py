# 将所有的查询语句进行编码，编码为一个连接矩阵加一个谓词向量

import os
import operator
from getResource import getResource
import psycopg2
from enum import Enum


querydir = '../resource/jobquery'   # imdb的113条查询语句
tablenamedir = '../resource/jobtablename'   # imdb的113条查询语句对应的查询表名（缩写）
queryplandir = '../resource/jobqueryplan'     # imdb的113条查询语句和其对应的查询计划
longtoshortpath = '../resource/longtoshort'   # 表的全名到缩写的映射，共21个（有些被覆盖了）
shorttolongpath = '../resource/shorttolong'   # 表的缩写到全名的映射，共28个
predicatesEncodeDictpath = './predicatesEncodedDict'   # 谓词的编码
queryEncodeDictpath = './queryEncodedDict'   # 查询语句的编码


# 所有常见谓词的枚举类，用于获取属性列选择率时传入参数以区分操作
class Predicate(Enum):
    EQ = 1
    NEQ = 2
    BG = 3
    BGE = 4
    L = 5
    LE = 6
    LIKE = 7
    NOT_LIKE = 8
    IS_NULL = 9
    IS_NOT_NULL = 10
    BETWEEN = 11
    NOT_BETWEEN = 12
    IN = 13


# 编码为连接矩阵+谓词向量
queryEncodeDict = {}
joinEncodeDict = {}
predicatesEncodeDict = {}


# 初始化连接矩阵和谓词向量
joinEncode = []
predicatesEncode = []


# 数据库连接参数
print("connecting...")
conn = psycopg2.connect(database="imdb", user="imdb", password="imdb", host="localhost", port="5432")
cur = conn.cursor()
print("connect success")


# 得到所有的attribution，用于进行选择过滤向量
def getQueryAttributions():
    fileList = os.listdir(querydir)
    fileList.sort()
    attr = set()

    for queryName in fileList:
        querypath = querydir + "/" + queryName
        file_object = open(querypath)
        file_context = file_object.readlines()
        file_object.close()

        # k记录WHERE的下标
        k = -1
        for i in range(len(file_context)):
            k = k + 1
            if file_context[i].find("WHERE") != -1:
                break

        # 处理WHERE后面的筛选条件，获取attribution
        for i in range(k, len(file_context)):
            temp = file_context[i].split()
            for word in temp:
                if '.' in word:
                    # word是字符串，不是attribution，不处理
                    if word[0] == "'":
                        continue
                    attr.add(filter(word))

    attrNames = list(attr)
    attrNames.sort()
    return attrNames


# 得到了所有的attribution，接下来可以做编码
def getQueryEncode(attrNames):
    # 读取所有表的缩写
    f = open(shorttolongpath, 'r')
    a = f.read()
    short_to_long = eval(a)
    f.close()

    # 读取表名缩写
    tableNames = []
    for i in short_to_long:
        tableNames.append(i)
    tableNames.sort()

    # 表名缩写与数字（列表下标）的映射
    table_to_int = {}
    int_to_table = {}
    for i in range(len(tableNames)):
        int_to_table[i] = tableNames[i]
        table_to_int[tableNames[i]] = i

    # 属性与数字（列表下标）的映射
    attr_to_int = {}
    int_to_attr = {}
    for i in range(len(attrNames)):
        int_to_attr[i] = attrNames[i]
        attr_to_int[attrNames[i]] = i

    fileList = os.listdir(querydir)
    fileList.sort()
    for queryName in fileList:

        # 初始化连接矩阵和谓词向量
        joinEncode = [0 for _ in range(len(tableNames)*len(tableNames))]
        predicatesEncode = [0 for _ in range(len(attrNames))]

        # 读取query语句
        querypath = querydir + "/" + queryName
        file_object = open(querypath)
        file_context = file_object.readlines()
        file_object.close()

        # k记录WHERE的下标
        k = -1
        for i in range(len(file_context)):
            k = k + 1
            if file_context[i].find("WHERE") != -1:
                break

        # 处理WHERE后面的谓词筛选条件
        for i in range(k, len(file_context)):
            temp = file_context[i].split()

            # 处理 '=' 谓词
            if "=" in temp:
                index = temp.index("=")

                # 等值连接: '=' 谓词前后均为attribution
                if (filter(temp[index - 1]) in attrNames) & (filter(temp[index + 1]) in attrNames):
                    table1 = temp[index - 1].split('.')[0]
                    table2 = temp[index + 1].split('.')[0]
                    # 连接矩阵对应位置设置为1表示i两个表之间存在连接关系
                    joinEncode[table_to_int[table1] * len(tableNames) + table_to_int[table2]] = 1
                    joinEncode[table_to_int[table2] * len(tableNames) + table_to_int[table1]] = 1

                # 选择过滤: '=' 谓词后为具体数据
                else:
                    paramlist = []
                    table = temp[index - 1].split('.')[0]
                    tablename = short_to_long[table]
                    # 获取过滤阈值
                    paramlist.append(temp[index + 1])
                    for word in temp:
                        if '.' in word:
                            if word[0] == "'":
                                continue
                            word = filter(word)
                            predicatesEncode[attr_to_int[word]] = getAttributionProportion(tablename, word.split('.')[1], Predicate.EQ, paramlist)

            # 处理 '!=' 谓词
            elif "!=" in temp:
                index = temp.index("!=")
                paramlist = []
                table = temp[index - 1].split('.')[0]
                tablename = short_to_long[table]
                # 获取过滤阈值
                paramlist.append(temp[index + 1])
                for word in temp:
                    if '.' in word:
                        if word[0] == "'":
                            continue
                        word = filter(word)
                        predicatesEncode[attr_to_int[word]] = getAttributionProportion(tablename, word.split('.')[1], Predicate.NEQ, paramlist)

            # 处理 '>'谓词
            elif ">" in temp:
                index = temp.index(">")
                paramlist = []
                table = temp[index - 1].split('.')[0]
                tablename = short_to_long[table]
                # 获取过滤阈值
                paramlist.append(temp[index + 1])
                for word in temp:
                    if '.' in word:
                        if word[0] == "'":
                            continue
                        word = filter(word)
                        predicatesEncode[attr_to_int[word]] = getAttributionProportion(tablename, word.split('.')[1], Predicate.BG, paramlist)

            # 处理 '<'谓词
            elif "<" in temp:
                index = temp.index("<")
                paramlist = []
                table = temp[index - 1].split('.')[0]
                tablename = short_to_long[table]
                # 获取过滤阈值
                paramlist.append(temp[index + 1])
                for word in temp:
                    if '.' in word:
                        if word[0] == "'":
                            continue
                        word = filter(word)
                        predicatesEncode[attr_to_int[word]] = getAttributionProportion(tablename, word.split('.')[1], Predicate.L, paramlist)

            # 处理 '>='谓词
            elif ">=" in temp:
                index = temp.index(">=")
                paramlist = []
                table = temp[index - 1].split('.')[0]
                tablename = short_to_long[table]
                # 获取过滤阈值
                paramlist.append(temp[index + 1])
                for word in temp:
                    if '.' in word:
                        if word[0] == "'":
                            continue
                        word = filter(word)
                        predicatesEncode[attr_to_int[word]] = getAttributionProportion(tablename, word.split('.')[1], Predicate.BGE, paramlist)

            # 处理 '<='谓词
            elif "<=" in temp:
                index = temp.index("<=")
                paramlist = []
                table = temp[index - 1].split('.')[0]
                tablename = short_to_long[table]
                # 获取过滤阈值
                paramlist.append(temp[index + 1])
                for word in temp:
                    if '.' in word:
                        if word[0] == "'":
                            continue
                        word = filter(word)
                        predicatesEncode[attr_to_int[word]] = getAttributionProportion(tablename, word.split('.')[1], Predicate.LE, paramlist)

            else:
                for word in temp:
                    if '.' in word:
                        if word[0] == "'":
                            continue
                        word = filter(word)
                        predicatesEncode[attr_to_int[word]] = 1

        predicatesEncodeDict[queryName[:-4]] = predicatesEncode
        queryEncodeDict[queryName[:-4]] = joinEncode + predicatesEncode

    f = open(predicatesEncodeDictpath, 'w')
    f.write(str(predicatesEncodeDict))
    f.close()

    f = open(queryEncodeDictpath, 'w')
    f.write(str(queryEncodeDict))
    f.close()

    cur.close()
    conn.close()

    print("done")


# 处理属性列，将(A.a1... 或 A.a1; 处理为A.a1
def filter(word):
    # 剪切掉左括号符号（不会出现含右括号的情况）
    if word[0] == '(':
        word = word[1:]
    # 剪切掉分号（sql语句末尾）
    if word[-1] == ';':
        word = word[:-1]

    return word


def getAttributionProportion(tablename, attname, predicate, paramlist):
    sql = '''
    SELECT null_frac,
           n_distinct,
           most_common_vals,
           most_common_freqs,
           histogram_bounds
    FROM pg_stats 
    WHERE tablename = '%s' and attname = '%s';
    ''' % (tablename, attname)
    cur.execute(sql)
    rows = cur.fetchall() # 这个查询只返回一行数据

    for row in rows:
        null_frac = row[0] # real
        n_distinct = row[1] # real
        most_common_vals = res_split(row[2]) # list
        most_common_freqs = row[3] # list
        histogram_bounds = res_split(row[4]) # list,不包含most_common_val的统计
    
    # 该属性列上有唯一性约束，则查询表的行数估计作为不同值个数
    if n_distinct == -1:
        sql = '''
        SELECT reltuples
        FROM pg_class
        WHERE relkind = 'r' AND relname = '%s';
        ''' % (tablename)
        cur.execute(sql)
        rows = cur.fetchall()

        for row in rows:
            n_distinct = row[0]

    selectivity = 0.0
    # 针对不同谓词情况分别计算选择率
    # FIXME: LIKE/NOT LIKE谓词暂未处理
    if predicate == Predicate.EQ or predicate == Predicate.NEQ:
        param = paramlist[0]
        sum_of_most_common_freqs = 0.0
        # 查找最常值，若参数在最常值中，则直接返回其频率作为选择率
        index = 0
        for val in most_common_vals:
            sum_of_most_common_freqs += most_common_freqs[index]
            if operator.eq(val, param):
                if predicate == Predicate.EQ:
                    selectivity = most_common_freqs[index]
                else:
                    selectivity = 1 - most_common_freqs[index]
                return selectivity
            index = index + 1
        if predicate == Predicate.EQ:
            selectivity = (1 - sum_of_most_common_freqs) / (n_distinct - len(most_common_vals))
        else:
            selectivity = 1 - (1 - sum_of_most_common_freqs) / (n_distinct - len(most_common_vals))
       
    elif predicate == Predicate.BG or predicate == Predicate.BGE or predicate == Predicate.L or predicate == Predicate.LE: 
        param = paramlist[0]
        sum_of_most_common_freqs = 0.0
        # 查找直方图信息，找到参数所在的bucket的index
        index = 0
        num_buckets = len(histogram_bounds) - 1
        for val in histogram_bounds:
            if operator.le(param, val):
                break
            index = index + 1
        if predicate == Predicate.BG or predicate == Predicate.BGE:
            selectivity = 1 - index / num_buckets
        else:
            selectivity = index / num_buckets
        
    elif predicate == Predicate.LIKE:
        selectivity = 1.0

    elif predicate == Predicate.NOT_LIKE:
        selectivity = 1.0

    elif predicate == Predicate.IS_NULL:
        selectivity = null_frac

    elif predicate == Predicate.IS_NOT_NULL:
        selectivity = 1 - null_frac
        
    elif predicate == Predicate.BETWEEN or predicate == Predicate.NOT_BETWEEN:
        begin = paramlist[0]
        end = paramlist[1]
        index1 = 0
        index2 = 0
        num_buckets = len(histogram_bounds) - 1
        # 查找直方图，统计begin和end参数之间的buckt数
        for val in histogram_bounds:
            if operator.le(begin, val):
                break
            index1 = index1 + 1
        index2 = index1 + 1
        while index2 < num_buckets:
            if operator.le(end, histogram_bounds[index2]):
                break
            index2 = index2 + 1
        if predicate == Predicate.BETWEEN:
            selectivity = (index2 - index1) / num_buckets
        else:
            selectivity = 1 - (index2 - index1) / num_buckets
        
    elif predicate == Predicate.IN:
        sum_of_most_common_freqs = 0.0
        # 计算所有最常值的频率
        for val in most_common_freqs:
            sum_of_most_common_freqs += val

        # 标准选择率，与等值过滤的选择率相同
        normal_selectivity = (1 - sum_of_most_common_freqs) / (n_distinct - len(most_common_vals))

        # 查找参数列表中每个参数是否在最常值中
        for param in paramlist:
            # 查找最常值，若参数在最常值中，则累加其频率
            index = 0
            flag = False
            for val in most_common_vals:
                if operator.eq(val, param):
                    selectivity = selectivity + most_common_freqs[index]
                    flag = True
                    break
                index = index + 1
            # 若不在最常值中，则累加标准选择率
            if not flag:
                selectivity = selectivity + normal_selectivity

    else:
        print('BAD PREDICATE' + str(predicate))
        sys.exit()

    return selectivity


def res_split(resStr):
    '''
    pg数据库查询pg_stats表返回结果中，most_commoin_vals 和 histogram_bounds的返回结果
    是一整行的字符串，需要进行分割得到期望的list，分隔符是: ,
    注意以下几种特殊情况：
    1. 返回结果对包含空格的字符串添加的双引号，需要去除
    2. 返回结果中双引号包含转义字符 \ 来转移双引号
    3. 某个字符串中可能包含','，因此不能简单地用','分割，这里用扫描字符串的形式
    流程如下：
    从前往后扫描，若是双引号，则表明一个单词的开始，接着扫描到下一个双引号且前驱不是'\'的时候结束
    (当单词内包含空格或不是分隔符含义的','时需要双引号括起来)
    若不是双引号，则扫描到下一个','时得到一个单词
    '''
    res = []
    if resStr is not None:
        resStr = resStr[1:-1] # 将字符串两端的花括号去除
        print()
        begin = 0
        end = 0
        while begin < len(resStr):
            # 以双引号开头的单词分割
            if resStr[begin] == '"':
                end = begin + 1
                while end < len(resStr):
                    # 以双引号结束，表示一个单词的完整出现
                    if resStr[end] == '"' and resStr[end - 1] != '\\':
                        print(resStr[begin + 1 : end],begin + 1,end,len(resStr))
                        res.append(resStr[begin + 1 : end]) # 去掉双引号，并将单词加入list
                        begin = end + 1
                        if begin < len(resStr) and resStr[begin] == ',':
                            begin = begin + 1
                        break
                    # 继续扫描
                    else:
                        end = end + 1
            # 常规开头，逗号分割
            else:
                end = begin + 1
                while end < len(resStr):
                    if resStr[end] == ',':
                        print(resStr[begin : end],begin,end,len(resStr))
                        res.append(resStr[begin : end])
                        begin = end + 1
                        break
                    else:
                        end = end + 1
                # 最后一个情况特殊处理，因为没有逗号结尾了
                if end == len(resStr):
                    print(resStr[begin : end],begin,end,len(resStr))
                    res.append(resStr[begin : end])
                    begin = end + 1
    print('split done')
    return res


if __name__ == '__main__':
    getResource()
    attrNames = getQueryAttributions()
    getQueryEncode(attrNames)




