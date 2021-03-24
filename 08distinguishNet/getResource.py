# getResource()函数更新，long_to_short， short_to_long，name_to_cost，将原始表名顺序转存到对应queryName文件中
# 将原始的查询计划直接表示为pghint可以接受的括号形式,存入lableDect

import os
import numpy as np
import psycopg2

querydir = '../resource/jobquery'  # imdb的113条查询语句
tablenamedir = '../resource/jobtablename'  # imdb的113条查询语句对应的查询表名（缩写）
queryplandir = '../resource/jobqueryplan'  # imdb的113条查询语句和其对应的查询计划
longtoshortpath = '../resource/longtoshort'  # 表的全名到缩写的映射，共21个（有些被覆盖了）
shorttolongpath = '../resource/shorttolong'  # 表的缩写到全名的映射，共39个
nametocostpath = "../resource/nametocost"

# labledir = './joblable'  # 查询语句对应的执行计划的表的顺序，从先连到后连，使用缩写
# testdir = './jobtest'
# labledectpath = './lableDect'


def getResource():
    conn = psycopg2.connect(database="imdb", user="imdb", password="imdb", host="localhost", port="5432")
    cur = conn.cursor()

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
        # queryName = "9d.sql"
        # 处理查询得到表的简写，顺序同查询中的顺序
        querypath = querydir + "/" + queryName
        file_object = open(querypath)
        file_context = file_object.readlines()
        # print(file_context)
        file_object.close()

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

        # 将原始表名顺序转存到对应queryName文件中，更新tablename
        for i in range(j, k - 1):
            temp = file_context[i].split()
            print(temp[temp.index("AS") + 1][:-1])
            tablenames.append(temp[temp.index("AS") + 1][:-1].lower())
        temp = file_context[k - 1].split()
        tablenames.append(temp[temp.index("AS") + 1].lower())

        f = open(tablenamedir + "/" + queryName[:-4], 'w')
        f.write(str(tablenames))
        f.close()
        # print(queryName, tablenames)

        # 读取查询
        querypath = querydir + "/" + queryName
        file_object = open(querypath)
        file_context = file_object.read()
        file_object.close()

        # 获取查询计划
        cur.execute("explain " + file_context)
        rows = cur.fetchall()  # all rows in table

        # 保存所有的查询和查询计划，更新queryplan
        queryplanpath = queryplandir + "/" + queryName
        file_object = open(queryplanpath, 'w')
        file_object.write(file_context + '\n\n')
        queryplan = []
        for line in rows:
            file_object.write(line[0] + '\n')
            queryplan.append(line[0])
        file_object.close()

        # 更新nametocost
        origin_cost = rows[0][0].split("=")[1]
        origin_cost = origin_cost.split("..")[0]
        origin_cost = float(origin_cost)
        name = queryName[0:-4]
        name_to_cost[name] = origin_cost

        # 将原始的查询计划直接表示为pghint可以接受的括号形式,存入lableDect
        lableDect[queryName[:-4]] = getHint(queryplan, 0, len(queryplan))
        print(queryName, lableDect[queryName[:-4]])

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

    # print(len(long_to_short))
    print(len(short_to_long))

    # f = open(nametocostpath, 'w')
    # f.write(str(name_to_cost))
    # f.close()
    #
    # # 保存括号形式的lableDect字典
    # f = open(labledectpath, 'w')
    # f.write(str(lableDect))
    # f.close()

    # 将两个字典转存到对应文件中
    f = open(longtoshortpath, 'w')
    f.write(str(long_to_short))
    f.close()
    f = open(shorttolongpath, 'w')
    f.write(str(short_to_long))
    f.close()

    cur.close()
    conn.close()


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


def cmp1(a):
    sum = 0
    for i in a:
        if i == ' ':
            sum += 1
    return -sum


def del_file(path):
    ls = os.listdir(path)
    for i in ls:
        c_path = os.path.join(path, i)
        if os.path.isdir(c_path):
            del_file(c_path)
        else:
            os.remove(c_path)


if __name__ == '__main__':
    getResource()
    # getLabel()
