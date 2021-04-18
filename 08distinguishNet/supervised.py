# coding=utf-8

from datetime import datetime
import time
import random
import os
import numpy as np
import torch
import pickle
from models import ValueNet

shortToLongPath = '../resource/shorttolong'
queryEncodedDictPath = './queryEncodedDict'  # 查询的编码


class data:
    def __init__(self, queryname, state, origintime, neotime, qpopttime, label):
        self.queryname = queryname
        self.state = state
        self.origintime = origintime
        self.neotime = neotime
        self.qpopttime = qpopttime
        self.label = label

    def __str__(self):
        print('query name: ' + self.queryname)
        print('state: ' + str(self.state))
        print('origintime: ' + str(self.origintime))
        print('neotime: ' + str(self.neotime))
        print('qpopttime: ' + str(self.qpopttime))
        print('label: ' + str(self.label))
        return ''


class supervised:
    def __init__(self, args):
        self.num_inputs = 856  # 预测网络输入的向量的维度
        self.num_output = 2  # 网络输出的向量的维度
        self.args = args

        # build up the network
        self.actor_net = ValueNet(self.num_inputs, self.num_output)
        self.actor_net.apply(self.init_weights)
        if self.args.cuda:
            self.actor_net.cuda()

        # check some dir
        if not os.path.exists(self.args.save_dir):
            os.mkdir(self.args.save_dir)

        # 读取字典-predicatesEncoded编码
        f = open(queryEncodedDictPath, 'r')
        a = f.read()
        self.queryEncodedDict = eval(a)
        f.close()

        # 读取所有表名,获取表名数字映射
        tables = []
        f = open(shortToLongPath, 'r')
        a = f.read()
        short_to_long = eval(a)
        f.close()
        for i in short_to_long.keys():
            tables.append(i)
        tables.sort()
        self.table_to_int = {}
        for i in range(len(tables)):
            self.table_to_int[tables[i]] = i

        self.datasetnumber = 10 
        self.trainList = []
        self.testList = []

    def pretreatment(self, path):
        print("Pretreatment running...")
        # 统一读入数据 随机抽取进行训练
        file_test = open(path)
        line = file_test.readline()
        dataList = []
        while line:
            # 解构训练集
            queryName = line.split(",")[0].encode('utf-8').decode('utf-8-sig').strip()
            state = self.queryEncodedDict[queryName]
            origintime = int(float(line.split(",")[1].strip()))
            neotime = int(float(line.split(",")[2].strip()))
            qpopttime = int(float(line.split(",")[3].strip()))
            label = int(line.split(",")[4].strip())
            temp = data(queryName, state, origintime, neotime, qpopttime, label)
            dataList.append(temp)
            line = file_test.readline()

        random.shuffle(dataList)
        listtemp = []
        for i in range(self.datasetnumber):
            temptemp = []
            listtemp.append(temptemp)
        for i in range(dataList.__len__()):
            listtemp[i % listtemp.__len__()].append(dataList[i])
        for i in range(listtemp.__len__()):
            filepath = "./data/data" + str(i) + ".sql"
            file = open(filepath, 'wb')
            pickle.dump(len(listtemp[i]), file)
            for value in listtemp[i]:
                pickle.dump(value, file)
            file.close()
        print('Pretreatment done.')

    def printdata(self):
        for a in self.trainList:
            print(a)


    def supervised(self):

        # model_path = self.args.save_dir + 'supervised.pt'
        # self.actor_net.load_state_dict(torch.load(model_path, map_location=lambda storage, loc: storage))
        # self.actor_net.eval()

        self.load_data()

        optim = torch.optim.SGD(self.actor_net.parameters(), lr=0.0005)
        loss_func = torch.nn.MSELoss()
        loss1000 = 0
        count = 0

        for step in range(1, 300001):
            index = random.randint(0, len(self.trainList) - 1)
            state = self.trainList[index].state
            state_tensor = torch.tensor(state, dtype=torch.float32)

            predictionRuntime = self.actor_net(state_tensor)
            label = [0 for _ in range(self.num_output)]
            label[self.trainList[index].label] = 1
            label_tensor = torch.tensor(label, dtype=torch.float32)

            loss = loss_func(predictionRuntime, label_tensor)
            optim.zero_grad()  # 清空梯度
            loss.backward()  # 计算梯度
            optim.step()  # 应用梯度，并更新参数
            loss1000 += loss.item()

            if step % 100000 == 0:
                torch.save(self.actor_net.state_dict(), self.args.save_dir + 'supervised-{:d}-{:.3f}.pt'.format(count, loss1000))
                count = count + 1
                # self.test_network()
            if step % 1000 == 0:
                print('[{}]  Epoch: {}, Loss: {:.5f}'.format(datetime.now(), step, loss1000))
                loss1000 = 0
        # torch.save(self.actor_net.state_dict(), self.args.save_dir + 'supervised.pt')

    # functions to test the network
    def test_network(self):
        self.load_data()
        model_path = self.args.save_dir + 'supervised-0-132.531.pt'
        self.actor_net.load_state_dict(torch.load(model_path, map_location=lambda storage, loc: storage))
        self.actor_net.eval()

        # 测试集
        correct = 0
        with torch.no_grad():
            for step in range(self.testList.__len__()):
                state = self.testList[step].state
                state_tensor = torch.tensor(state, dtype=torch.float32)

                prediction = self.actor_net(state_tensor).detach().cpu().numpy()
                maxindex = np.argmax(prediction)
                print(self.testList[step].queryname, ",", self.testList[step].origintime, ",",
                        self.testList[step].neotime, ",", self.testList[step].qpopttime, ",",
                        self.testList[step].label, ",", maxindex)
                if maxindex == self.testList[step].label:
                    correct += 1
            print("测试集：", correct, "\t", self.testList.__len__())

            # 训练集
            correct1 = 0
            for step in range(self.trainList.__len__()):
                state = self.trainList[step].state
                state_tensor = torch.tensor(state, dtype=torch.float32)

                predictionRuntime = self.actor_net(state_tensor)
                prediction = predictionRuntime.detach().cpu().numpy()
                maxindex = np.argmax(prediction)
                label = self.trainList[step].label
                # print(self.trainList[step].queryname.strip(), "\t", label, "\t", maxindex)
                if maxindex == label:
                    correct1 += 1
            print("训练集", correct1, "\t", self.trainList.__len__())

    def load_data(self, testnum=0):
        if self.trainList.__len__() != 0:
            return

        testpath = "./data/data" + str(testnum) + ".sql"
        file_test = open(testpath, 'rb')
        l = pickle.load(file_test)
        for _ in range(l):
            self.testList.append(pickle.load(file_test))
        file_test.close()

        for i in range(self.datasetnumber):
            if i == testnum:
                continue
            trainpath = "./data/data" + str(i) + ".sql"
            file_train = open(trainpath, 'rb')
            l = pickle.load(file_train)
            for _ in range(l):
                self.trainList.append(pickle.load(file_train))
            file_train.close()
        print("load data\ttrainSet:", self.trainList.__len__(), " testSet:", self.testList.__len__())

    def init_weights(self, m):
        if type(m) == torch.nn.Linear:
            torch.nn.init.xavier_uniform_(m.weight)
            m.bias.data.fill_(0.01)
