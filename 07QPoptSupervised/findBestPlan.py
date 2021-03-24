from __future__ import division

import os
from copy import deepcopy
from mcts import mcts
import time

queryEncodeDictPath = './queryEncodedDict'  # 查询的编码
predicatesEncodeDictPath = './predicatesEncodedDict' # 谓词的编码
shorttolongpath = '../resource/shorttolong'  # 表的缩写到全名的映射，共39个
tablenamedir = '../resource/jobtablename'  # imdb的113条查询语句对应的查询表名（缩写）
querydir = "../resource/jobquery" # imdb的113条查询语句

f = open(queryEncodeDictPath, 'r')
a = f.read()
queryEncodeDict = eval(a)
f.close()

f = open(predicatesEncodeDictPath, 'r')
a = f.read()
predicatesEncodeDict = eval(a)
f.close()

# 读取表名称的缩写
tables = []
f = open(shorttolongpath, 'r')
a = f.read()
short_to_long = eval(a)
f.close()
for i in short_to_long.keys():
    tables.append(i)
tables.sort()

# 序号到缩写的映射及缩写到序号的映射
totalNumberOfTables = len(tables)
tableToInt = {}
intToTable = {}
for i in range(totalNumberOfTables):
    intToTable[i] = tables[i]
    tableToInt[tables[i]] = i

class planState:
    def __init__(self, totalNumberOfTables, numberOfTables, queryEncode, predicatesEncode):
        self.tableNumber = totalNumberOfTables
        self.currentStep = numberOfTables
        self.board = [0 for _ in range(self.tableNumber * self.tableNumber)]
        self.joinMartix = queryEncode[:self.tableNumber * self.tableNumber]
        self.predicatesEncode = predicatesEncode

    def getPossibleActions(self):
        possibleActions = []
        for i in range(self.tableNumber):
            for j in range(self.tableNumber):
                if self.joinMartix[i * self.tableNumber + j] == 1:
                    possibleActions.append(Action(self.currentStep, x=i, y=j))
        return possibleActions

    def takeAction(self, action):
        newState = deepcopy(self)
        newState.currentStep = self.currentStep - 1
        newState.board[action.x * self.tableNumber + action.y] = action.currentStep
        newState.joinMartix[action.x * self.tableNumber + action.y] = 0
        newState.joinMartix[action.y * self.tableNumber + action.x] = 0
        ma = max(action.x, action.y)
        mi = min(action.x, action.y)
        # FIXME： 这一步没看懂
        for i in range(self.tableNumber):
            if newState.joinMartix[i * self.tableNumber + ma] == 1:
                newState.joinMartix[i * self.tableNumber + ma] = 0
                newState.joinMartix[i * self.tableNumber + mi] = 1
            if newState.joinMartix[ma * self.tableNumber + i] == 1:
                newState.joinMartix[ma * self.tableNumber + i] = 0
                newState.joinMartix[mi * self.tableNumber + i] = 1
        return newState

    def isTerminal(self):
        if self.currentStep == 1:
            return True
        return False

    # 这个方法没用到
    # def splitList(self, datas, n):
    #     length = len(datas)
    #     size = int(length / n + 1 if length % n else length / n)
    #     _datas = []
    #     for i in range(n):
    #         start = i * size
    #         end = (i + 1) * size
    #         _datas.append(datas[i * size: (i + 1) * size])
    #     return _datas


class Action:
    def __init__(self, step, x, y):
        self.currentStep = step
        self.x = x
        self.y = y

    def __str__(self):
        return str((self.x, self.y))

    def __repr__(self):
        return str(self)

    def __eq__(self, other):
        return self.__class__ == other.__class__ and self.x == other.x and self.y == other.y and self.currentStep == other.currentStep

    def __hash__(self):
        return hash((self.x, self.y, self.currentStep))


def getCost(sql):
    cur.execute(sql)
    rows = cur.fetchall()  # all rows in table
    origin_cost = rows[0][0].split("=")[1]
    origin_cost = origin_cost.split("..")[0]
    origin_cost = float(origin_cost)
    return origin_cost


def decode(currentState, tableList):
    tempdect = {}
    for i in range(len(tableList)):
        tempdect[tableList[i]] = tableList[i]

    correctcount = 0  # 鐠佹澘缍嶆潻鐐村复閻ㄥ嫭鏆熼柌锟?
    while correctcount != len(tableList) - 1:
        index = currentState.board.index(max(currentState.board))  # 濮瑰倸娼楅弽锟?
        indexa = int(index / currentState.tableNumber)
        indexb = int(index % currentState.tableNumber)
        currentState.board[index] = 0

        string = "( " + tempdect[intToTable[indexa]] + " " + tempdect[intToTable[indexb]] + " )"
        correctcount += 1
        # 閺囧瓨鏌婄€涙鍚€
        for j in string.split():
            if j in tableList:
                tempdect[j] = string

    return tempdect[tableList[0]]


def findBestPlan():
    queryNameList = os.listdir(tablenamedir)
    queryNameList.sort()

    searchtime = 0
    for i in range(5) :
        searchtime += 5
        print(searchtime)
        for queryName in queryNameList:

            # 閼惧嘲褰囬弻銉嚄閻ㄥ嫯銆冮惃鍒瞚st
            tablenamepath = tablenamedir + "/" + queryName
            file_object = open(tablenamepath)
            file_context = file_object.read()
            tableList = eval(file_context)
            file_object.close()


            mct = mcts(iterationLimit=(int)(len(tableList) *  searchtime))
            initialState = planState(totalNumberOfTables, len(tableList), queryEncodeDict[queryName],
                                    predicatesEncodeDict[queryName])
            currentState = initialState
            start = time.time()
            start2 = time.clock()
            while currentState.currentStep != 1:
                action = mct.search(initialState=currentState)
                # print(action)
                currentState = currentState.takeAction(action)
            elapsed = (time.time() - start) * 1000
            elapsed2  = (time.clock() - start2) * 1000 / 96 
            hint = decode(currentState, tableList)

            print(queryName, ",", hint, ",%.3f" % elapsed, ",%.3f" % elapsed2)


if __name__ == '__main__':
    findBestPlan()
