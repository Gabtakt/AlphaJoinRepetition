# getResource()函数更新，long_to_short， short_to_long，name_to_cost，将原始表名顺序转存到对应queryName文件中
# 将原始的查询计划直接表示为pghint可以接受的括号形式,存入lableDect

import os
import numpy as np
import psycopg2

querydir = '../resource/jobquery'  # imdb的113条查询语句
tablenamedir = '../resource/jobtablename'  # imdb的113条查询语句对应的查询表名缩写
queryplandir = '../resource/jobqueryplan'  # imdb的113条查询语句和其对应的查询计划
longtoshortpath = '../resource/longtoshort'  # 表的全名到缩写的映射，共21个
shorttolongpath = '../resource/shorttolong'  # 表的缩写到全名的映射，共28个
nametocostpath = "../resource/nametocost" # 查询语句到开销的映射
labledectpath = './lableDect'


def getResource():
    print("connecting...")
    conn = psycopg2.connect(database="imdb", user="imdb", password="imdb", host="localhost", port="5432")
    cur = conn.cursor()
    print("connect success")

    # 全名到缩写的映射
    long_to_short = {}
    # 缩写到全名的映射
    short_to_long = {}
    # 缩写到cost的映射
    name_to_cost = {}
    lableDect = {}

    fileList = os.listdir(querydir)
    fileList.sort()
    for queryName in fileList:
        # 处理查询得到表的简写，顺序同查询中的顺序
        querypath = querydir + "/" + queryName
        file_object = open(querypath)
        file_context = file_object.readlines()
        file_object.close()

        # i和k分别表示FROM子句和WHERE子句在查询语句中的位置
        j = 0
        k = 0
        tablenames = []
        for i in range(len(file_context)):
            if file_context[i].find("FROM") != -1:
                break
            j = j + 1
        for i in range(len(file_context)):
            if file_context[i].find("WHERE") != -1:
                break
            k = k + 1

        # 将原始表名缩写顺序转存到对应queryName文件中，更新jobtablename
        for i in range(j, k - 1):
            temp = file_context[i].split()
            # 这里的切片操作是剪切掉语句中的逗号，最后一个表不用处理
            tablenames.append(temp[temp.index("AS") + 1][:-1].lower())
        temp = file_context[k - 1].split()
        tablenames.append(temp[temp.index("AS") + 1].lower())

        f = open(tablenamedir + "/" + queryName[:-4], 'w')
        f.write(str(tablenames))
        f.close()

        # 读取查询
        querypath = querydir + "/" + queryName
        file_object = open(querypath)
        file_context = file_object.read()
        file_object.close()

        # 获取查询计划
        cur.execute("explain " + file_context)
        rows = cur.fetchall()  # all rows in table

        # 保存所有的查询和查询计划，更新jobqueryplan
        queryplanpath = queryplandir + "/" + queryName
        file_object = open(queryplanpath, 'w')
        file_object.write(file_context + '\n\n')
        queryplan = []
        for line in rows:
            file_object.write(line[0] + '\n')
            queryplan.append(line[0])
        file_object.close()

        # 更新nametocost
        # 查询计划第一行的形式: Aggregate  (cost=19531.49..19531.50 rows=1 width=68)
        origin_cost = rows[0][0].split("=")[1]
        origin_cost = origin_cost.split("..")[0]
        origin_cost = float(origin_cost)
        name = queryName[0:-4]
        name_to_cost[name] = origin_cost

        # # 将原始的查询计划直接表示为pghint可以接受的括号形式,存入lableDect
        lableDect[queryName[:-4]] = getHint(queryplan, 0, len(queryplan))

        # 更新long_to_short和long_to_short
        scan_language = []
        for line in rows:
            if line[0].find('Scan') != -1 & line[0].find('Bitmap Index') == -1:
                scan_language.append(line[0])
        for language in scan_language:
            word = language.split(' ')
            index = word.index('on')
            long_to_short[word[index + 1]] = word[index + 2]
            short_to_long[word[index + 2]] = word[index + 1]

    # 保存查询语句到开销的字典
    f = open(nametocostpath, 'w')
    f.write(str(name_to_cost))
    f.close()
    
    # 保存括号形式的lableDect字典
    f = open(labledectpath, 'w')
    f.write(str(lableDect))
    f.close()

    # 将两个字典转存到对应文件中
    f = open(longtoshortpath, 'w')
    f.write(str(long_to_short))
    f.close()
    f = open(shorttolongpath, 'w')
    f.write(str(short_to_long))
    f.close()

    cur.close()
    conn.close()

    print("done")


def getHint(queryplan, begin, end):
    if queryplan[begin].find('Scan') != -1 & queryplan[begin].find('Bitmap Index') == -1:
        language = queryplan[begin]
        word = language.split(' ')
        index = word.index('on')
        return word[index + 2]
    if begin == end:
        return

    bla = blank(queryplan[begin])
    count = 0
    for i in range(begin + 1, end):
        if blank(queryplan[i]) == bla + 6:
            count += 1
            if count == 2:
                a = getHint(queryplan, begin + 1, i)
                b = getHint(queryplan, i, end)
                return "( " + a + " " + b + " )"

    return getHint(queryplan, begin + 1, end)


def blank(line):
    for i in range(len(line)):
        if line[i] == '-':
            return i
    return -1


if __name__ == '__main__':
    getResource()
