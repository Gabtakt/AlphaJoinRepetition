from datetime import datetime
import random
import os
import numpy as np
import torch
import pickle
from models import ValueNet

shortToLongPath = '../resource/shorttolong'
predicatesEncodeDictPath = './predicatesEncodedDict'  # 查询的编码


class data:
    def __init__(self, state, time):
        self.state = state
        self.time = time
        self.label = 0


class supervised:
    def __init__(self, args):
        self.num_inputs = 856  # 预测网络输入的向量的维度
        self.num_output = 5  # 网络输出的向量的维度
        self.args = args
        self.right = 0


        # build up the network
        self.actor_net = ValueNet(self.num_inputs, self.num_output)
        if self.args.cuda:
            self.actor_net.cuda()

        # check some dir
        if not os.path.exists(self.args.save_dir):
            os.mkdir(self.args.save_dir)

        # 读取字典-predicatesEncoded编码
        f = open(predicatesEncodeDictPath, 'r')
        a = f.read()
        self.predicatesEncodeDict = eval(a)
        f.close()

        # 读取所有表名缩写,获取表名缩写到数字映射
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

        self.dataList = []
        self.testList = []

    def hint2matrix(self, hint):
        # 解构query plan
        tablesInQuery = hint.split(" ")
        # 对查询计划编码
        matrix = np.mat(np.zeros((28, 28)))
        stack = []
        chazhi = 0
        for i in tablesInQuery:
            if i == ')':
                tempb = stack.pop()
                tempa = stack.pop()
                _ = stack.pop()
                b = tempb.split('+')
                a = tempa.split('+')
                # 排序以后取用左边编号最小的那个表作为代表
                b.sort()
                a.sort()
                indexb = self.table_to_int[b[0]]
                indexa = self.table_to_int[a[0]]
                matrix[indexa, indexb] = (len(tablesInQuery) + 2) / 3 - chazhi
                chazhi += 1
                stack.append(tempa + '+' + tempb)
                # print(stack)
            else:
                stack.append(i)
        return matrix

    def pretreatment(self, path):
        # 统一读入数据 随机抽取进行训练
        file_test = open(path)
        line = file_test.readline()
        while line:
            # 解构训练集
            queryName = line.split(",")[0].encode('utf-8').decode('utf-8-sig').strip()
            hint = line.split(",")[1]
            matrix = self.hint2matrix(hint)
            predicatesEncode = self.predicatesEncodeDict[queryName]
            state = matrix.flatten().tolist()[0]
            state = predicatesEncode + state
            runtime = line.split(",")[2].strip()
            if runtime == 'timeout':  # 5 min = 300 s = 300 000 ms
                runtime = 300000
            else:
                runtime = int(float(runtime))
            temp = data(state, runtime)
            self.dataList.append(temp)
            line = file_test.readline()

        self.dataList.sort(key=lambda x: x.time, reverse=False)
        for i in range(self.dataList.__len__()):
            self.dataList[i].label = int(i / (self.dataList.__len__() / self.num_output + 1))
            # print(self.dataList[i].label)
        for i in range(int(self.dataList.__len__() * 0.3)):
            index = random.randint(0, len(self.dataList) - 1)
            temp = self.dataList.pop(index)
            self.testList.append(temp)

        print("size of test set:", len(self.testList), "\tsize of train set:", len(self.dataList))
        testpath = "./data/testdata.sql"
        file_test = open(testpath, 'wb')
        pickle.dump(len(self.testList), file_test)
        for value in self.testList:
            pickle.dump(value, file_test)
        file_test.close()

        trainpath = "./data/traindata.sql"
        file_train = open(trainpath, 'wb')
        pickle.dump(len(self.dataList), file_train)
        for value in self.dataList:
            pickle.dump(value, file_train)
        file_train.close()

    def supervised(self):

        #model_path = self.args.save_dir + 'supervised.pt'
        #self.actor_net.load_state_dict(torch.load(model_path, map_location=lambda storage, loc: storage))
        #self.actor_net.eval()

        self.load_data()

        optim = torch.optim.SGD(self.actor_net.parameters(), lr=0.01)
        #loss_func = torch.nn.MSELoss()
        loss_func = torch.nn.CrossEntropyLoss()
        loss1000 = 0
        count = 0

        # starttime = datetime.now()
        for step in range(1, 1600001):
            #self.test_network()
            #print(datetime.now())
            #continue
            index = random.randint(0, len(self.dataList) - 1)
            state = self.dataList[index].state
            state_tensor = torch.tensor(state, dtype=torch.float32)

            predictionRuntime = self.actor_net(state_tensor)
            label = [0 for _ in range(self.num_output)]
            label[self.dataList[index].label] = 1
            label_tensor = torch.tensor(label, dtype=torch.float32)

            #loss = loss_func(predictionRuntime, label_tensor)
            temp = []
            temp.append(self.dataList[index].label)
            print(torch.tensor(temp, dtype=torch.float32))
            print(predictionRuntime)
            loss = loss_func(predictionRuntime, torch.tensor(temp, dtype=torch.float32))
            optim.zero_grad()  # 清空梯度
            loss.backward()  # 计算梯度
            optim.step()  # 应用梯度，并更新参数
            loss1000 += loss.item()
            if step % 1000 == 0:
                print('[{}]  Epoch: {}, Loss: {:.5f}'.format(datetime.now(), step, loss1000))
                loss1000 = 0
            if step % 100000 == 0:
                torch.save(self.actor_net.state_dict(), self.args.save_dir + 'supervised.pt')
                #self.test_network()

    # functions to test the network
    def test_network(self):
        self.load_data()
        model_path = self.args.save_dir + 'supervised.pt'
        self.actor_net.load_state_dict(torch.load(model_path, map_location=lambda storage, loc: storage))
        self.actor_net.eval()

        correct = 0
        for step in range(self.testList.__len__()):
            state = self.testList[step].state
            state_tensor = torch.tensor(state, dtype=torch.float32)

            predictionRuntime = self.actor_net(state_tensor)
            prediction = predictionRuntime.detach().cpu().numpy()
            maxindex = np.argmax(prediction)
            label = self.testList[step].label
            #print(maxindex, "\t", label)
            if maxindex == label:
                correct += 1
        print(correct, self.testList.__len__( ), correct/self.testList.__len__(), end = ' ')

        correct1 = 0
        for step in range(self.dataList.__len__()):
            state = self.dataList[step].state
            state_tensor = torch.tensor(state, dtype=torch.float32)

            predictionRuntime = self.actor_net(state_tensor)
            # prediction = predictionRuntime.detach().cpu().numpy()[0]
            prediction = predictionRuntime.detach().cpu().numpy()
            maxindex = np.argmax(prediction)
            label = self.dataList[step].label
            #print(maxindex, "\t", label)
            if maxindex == label:
                correct1 += 1
        print(correct1, self.dataList.__len__(), correct1/self.dataList.__len__())
        #if abs(correct / self.testList.__len__() -  self.right) < 0.001:
        #    sys.exit()
        self.right = correct / self.testList.__len__()

    def test_hintcost(self, queryName, hint):
        model_path = self.args.save_dir + 'supervised.pt'

        self.actor_net.load_state_dict(torch.load(model_path, map_location=lambda storage, loc: storage))
        self.actor_net.eval()

        matrix = self.hint2matrix(hint)
        predicatesEncode = self.predicatesEncodeDict[queryName]
        state = matrix.flatten().tolist()[0]
        state = predicatesEncode + state
        state_tensor = torch.tensor(state, dtype=torch.float32)

        predictionRuntime = self.actor_net(state_tensor)
        prediction = predictionRuntime.detach().cpu().numpy()
        maxindex = np.argmax(prediction)
        print(maxindex)

    def load_data(self):
        if self.dataList.__len__() != 0:
            return
        testpath = "./data/testdata.sql"
        file_test = open(testpath, 'rb')
        l = pickle.load(file_test)
        for _ in range(l):
            self.testList.append(pickle.load(file_test))
        file_test.close()

        trainpath = "./data/traindata.sql"
        file_train = open(trainpath, 'rb')
        l = pickle.load(file_train)
        for _ in range(l):
            self.dataList.append(pickle.load(file_train))
        file_train.close()
