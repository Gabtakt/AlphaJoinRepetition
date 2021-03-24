# 将所有的查询语句进行编码，编码为一个连接矩阵加一个谓词向量

import os
from getResource import getResource

# 数据库连接参数
conn = psycopg2.connect(database="imdb", user="imdb", password="imdb", host="localhost", port="5432")
cur = conn.cursor()

querydir = '../resource/jobquery'   # imdb的113条查询语句
tablenamedir = '../resource/jobtablename'   # imdb的113条查询语句对应的查询表名（缩写）
queryplandir = '../resource/jobqueryplan'     # imdb的113条查询语句和其对应的查询计划
longtoshortpath = '../resource/longtoshort'   # 表的全名到缩写的映射，共21个（有些被覆盖了）
shorttolongpath = '../resource/shorttolong'   # 表的缩写到全名的映射，共39个

predicatesEncodeDictpath = './predicatesEncodedDict'   # 查询的编码
queryEncodeDictpath = './queryEncodedDict'   # 查询的编码

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

        # 找到WHERE在哪里
        k = -1
        for i in range(len(file_context)):
            k = k + 1
            if file_context[i].find("WHERE") != -1:
                break

        # 处理WHERE后面某句话
        for i in range(k, len(file_context)):
            temp = file_context[i].split()
            for word in temp:
                if '.' in word:
                    if word[0] == "'":
                        continue
                    if word[0] == '(':
                        word = word[1:]
                    if word[-1] == ';':
                        word = word[:-1]
                    attr.add(word)

    attrNames = list(attr)
    attrNames.sort()
    return attrNames


# 得到了所有的attribution，接下来可以做one-hot编码
def getQueryEncode(attrNames):

    # 读取所有表的缩写
    f = open(shorttolongpath, 'r')
    a = f.read()
    short_to_long = eval(a)
    f.close()
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
    # print(table_to_int)


    queryEncodeDict = {}
    joinEncodeDict = {}
    predicatesEncodeDict = {}
    # 编码为连接矩阵加上谓词向量
    fileList = os.listdir(querydir)
    fileList.sort()

    for queryName in fileList:

        joinEncode = [0 for _ in range(len(tableNames)*len(tableNames))]
        predicatesEncode = [0 for _ in range(len(attrNames))]

        # 读取query语句
        querypath = querydir + "/" + queryName
        file_object = open(querypath)
        file_context = file_object.readlines()
        file_object.close()

        # 找到WHERE在哪里
        k = -1
        for i in range(len(file_context)):
            k = k + 1
            if file_context[i].find("WHERE") != -1:
                break

        # 处理WHERE后面某句话
        for i in range(k, len(file_context)):
            temp = file_context[i].split()

            if "=" in temp:
                index = temp.index("=")
                if (filter(temp[index - 1]) in attrNames) & (filter(temp[index + 1]) in attrNames):
                    table1 = temp[index - 1].split('.')[0]
                    table2 = temp[index + 1].split('.')[0]
                    # print(table1, table2, temp,table_to_int[table1],table_to_int[table2])
                    joinEncode[table_to_int[table1] * len(tableNames) + table_to_int[table2]] = 1
                    joinEncode[table_to_int[table2] * len(tableNames) + table_to_int[table1]] = 1
                    # for i in range (0,len(tableNames)):
                    #     for j in range(0, len(tableNames)):
                    #         print(joinEncode[i*len(tableNames)+j],end=' ')
                    #     print()
                else:
                    for word in temp:
                        if '.' in word:
                            if word[0] == "'":
                                continue
                            if word[0] == '(':
                                word = word[1:]
                            if word[-1] == ';':
                                word = word[:-1]
                            # 2021-3-24 : change one-hot to histogram
                            predicatesEncode[attr_to_int[word]] = getAttributionProportion(word)
                            # predicatesEncode[attr_to_int[word]] = 1
            else:q
                for word in temp:
                    if '.' in word:
                        if word[0] == "'":
                            continue
                        if word[0] == '(':
                            word = word[1:]
                        if word[-1] == ';':
                            word = word[:-1]
                        predicatesEncode[attr_to_int[word]] = 1
        predicatesEncodeDict[queryName[:-4]] = predicatesEncode
        queryEncodeDict[queryName[:-4]] = joinEncode + predicatesEncode

    for i in queryEncodeDict.items():
        print(i)
    print(len(tableNames), tableNames)
    print(len(attrNames), attrNames)

    f = open(predicatesEncodeDictpath, 'w')
    f.write(str(predicatesEncodeDict))
    f.close()
    f = open(queryEncodeDictpath, 'w')
    f.write(str(queryEncodeDict))
    f.close()


def filter(word):
    if '.' in word:
        if word[0] == '(':
            word = word[1:]
        if word[-1] == ';':
            word = word[:-1]
    return word

def getAttributionProportion(tablename, attname):
    sql = "select histogram_bounds from pg_stats where tablename = '%s' and attname = '%s';" % (tablename, attname)
    cur.execute(sql)
    rs=cur.fetchall()
    for line in rs:
        print(line)
    return 1



if __name__ == '__main__':
    getResource()
    attrNames = getQueryAttributions()
    getQueryEncode(attrNames)




