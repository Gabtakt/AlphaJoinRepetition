# 将所有的查询语句进行编码，编码为一个连接矩阵加一个谓词向量

import os
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
    rows = cur.fetchall()
    if len(rows) == 0 :
        print(tablename + "," + attname + "," + " " + len(rows))

    selectivity = 0.0



    return 1


if __name__ == '__main__':
    getResource()
    attrNames = getQueryAttributions()
    getQueryEncode(attrNames)




