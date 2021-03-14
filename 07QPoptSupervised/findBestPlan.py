from __future__ import division

import os
from copy import deepcopy
from mcts import mcts
import time
# import psycopg2
#
# conn = psycopg2.connect(database="imdb2017", user="ohlala", password="wwww", host="localhost", port="5432")
# cur = conn.cursor()

queryEncodeDictPath = './queryEncodedDict'  # 閺屻儴顕楅惃鍕椽閻拷
predicatesEncodeDictPath = './predicatesEncodedDict'
shorttolongpath = '../resource/shorttolong'  # 鐞涖劎娈戠紓鈺佸晸閸掓澘鍙忛崥宥囨畱閺勭姴鐨犻敍灞藉彙39娑擄拷
tablenamedir = '../resource/jobtablename'  # imdb閻拷113閺夆剝鐓＄拠銏ｎ嚔閸欍儱顕惔鏃傛畱閺屻儴顕楃悰銊ユ倳閿涘牏缂夐崘娆欑礆
querydir = "../resource/jobquery"

f = open(queryEncodeDictPath, 'r')
a = f.read()
queryEncodeDict = eval(a)
f.close()

f = open(predicatesEncodeDictPath, 'r')
a = f.read()
predicatesEncodeDict = eval(a)
f.close()

# 閼惧嘲褰囬幍鈧張澶庛€冮崥宥忕礄缂傗晛鍟撹ぐ銏犵础閿涳拷
tables = []
f = open(shorttolongpath, 'r')
a = f.read()
short_to_long = eval(a)
f.close()
for i in short_to_long.keys():
    tables.append(i)
tables.sort()

# 鐞涖劌鎮曠紓鈺佸晸娑撳孩鏆熺€涙绱欓崚妤勩€冩稉瀣垼閿涘娈戦弰鐘茬殸
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
        # self.tableList = tableList
        # self.query = query
        # self.origincost = originalcost

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

    # def getReward(self):
    #     if self.currentStep == 1:
    #         hint = decode(self, self.tableList)
    #         sql = "/*+ Leading(" + hint + " ) */ \n explain " + self.query
    #         cost = getCost(sql)
    #         return 1.0 / (cost / self.origincost)
    #     return False

    def splitList(self, datas, n):
        length = len(datas)
        size = int(length / n + 1 if length % n else length / n)
        _datas = []
        for i in range(n):
            start = i * size
            end = (i + 1) * size
            _datas.append(datas[i * size: (i + 1) * size])
        return _datas


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
