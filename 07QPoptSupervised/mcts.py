from __future__ import division

import time
import math
import random
from copy import deepcopy

import numpy as np
from models import ValueNet
import torch
model_path = './saved_models/supervised.pt'

# 加载预先训练好的价值网络
predictionNet = ValueNet(856, 5)
predictionNet.load_state_dict(torch.load(model_path, map_location=lambda storage, loc: storage))
predictionNet.eval()


# 根据价值网络的输出计算其奖励
def getReward(state):
    inputState = torch.tensor(state.predicatesEncode + state.board, dtype=torch.float32)
    print(inputState)
    # 仅根据编码输入计算输出，不更新梯度
    with torch.no_grad():
        predictionRuntime = predictionNet(inputState)
    prediction = predictionRuntime.detach().cpu().numpy()
    maxindex = np.argmax(prediction)
    # FIXME:这里为什么是用10减而不是5减
    reward = 10 - maxindex
    return reward


# 默认策略: 随机选择一个节点进行拓展
def randomPolicy(state):
    while not state.isTerminal():
        try:
            temp = state.getPossibleActions()
            action = random.choice(temp)
        except IndexError:
            raise Exception("Non-terminal state has no possible actions: " + str(state))
        state = state.takeAction(action)
    reward = getReward(state)
    # print(reward)
    return reward


class treeNode():
    def __init__(self, state, parent):
        self.state = state # 保存树的状态结构，state的定义在findBestPlan中PlanState
        self.isTerminal = state.isTerminal() # 表示该节点是否达到终止状态
        self.isFullyExpanded = self.isTerminal # 表示该节点是否已完全拓展
        self.parent = parent # 父节点
        self.numVisits = 0 # 记录节点访问次数
        self.totalReward = 0 # 记录节点奖励值，与numVisit一起用于UCT算法以平衡探索和利用
        self.children = {} # 子节点列表，是Planstate到treeNode的字典


# 蒙特卡洛树搜索
class mcts():
    def __init__(self, timeLimit=None, iterationLimit=None, explorationConstant=1 / math.sqrt(2),
                 rolloutPolicy=randomPolicy):
        if timeLimit != None:
            if iterationLimit != None:
                raise ValueError("Cannot have both a time limit and an iteration limit")
            # time taken for each MCTS search in milliseconds
            self.timeLimit = timeLimit
            self.limitType = 'time'
        else:
            if iterationLimit == None:
                raise ValueError("Must have either a time limit or an iteration limit")
            # number of iterations of the search
            if iterationLimit < 1:
                raise ValueError("Iteration limit must be greater than one")
            self.searchLimit = iterationLimit
            self.limitType = 'iterations'
        self.explorationConstant = explorationConstant
        self.rollout = rolloutPolicy

    # 从根节点开始进行搜索，根据限制类型的不同调用executeRound()进行搜索
    def search(self, initialState):
        self.root = treeNode(initialState, None)

        if self.limitType == 'time':
            timeLimit = time.time() + self.timeLimit / 1000
            while time.time() < timeLimit:
                self.executeRound()
        else:
            for i in range(self.searchLimit):
                self.executeRound()

        bestChild = self.getBestChild(self.root, 0)
        return self.getAction(self.root, bestChild)

    # 对选择的节点进行快速rollout，获取收益后，调用backpropogate()进行反向传播
    def executeRound(self):
        node = self.selectNode(self.root)
        newState = deepcopy(node.state)
        reward = self.rollout(newState)
        self.backpropogate(node, reward)

    # 选择当前节点的一个子节点，若已完全拓展则选择最佳子节点，否则进行拓展
    def selectNode(self, node):
        while not node.isTerminal:
            if node.isFullyExpanded:
                node = self.getBestChild(node, self.explorationConstant)
            else:
                return self.expand(node)
        return node

    # 获取当前节点所有可能的子节点进行拓展
    def expand(self, node):
        actions = node.state.getPossibleActions()
        for action in actions:
            if action not in node.children:
                newNode = treeNode(node.state.takeAction(action), node)
                node.children[action] = newNode
                if len(actions) == len(node.children):
                    node.isFullyExpanded = True
                # if newNode.isTerminal:
                #     print(newNode)
                return newNode

        raise Exception("Should never reach here")

    # 对当前路径上所有节点进行反向传播，更新参数
    def backpropogate(self, node, reward):
        while node is not None:
            node.numVisits += 1
            node.totalReward += reward
            node = node.parent

    # 获取当前节点的最佳子节点，根据UCT算法进行选择
    def getBestChild(self, node, explorationValue):
        bestValue = float("-inf")
        bestNodes = []
        # 计算每个子节点的价值，选择价值最大的子节点
        for child in node.children.values():
            nodeValue = child.totalReward / child.numVisits + explorationValue * math.sqrt(
                2 * math.log(node.numVisits) / child.numVisits)
            if nodeValue > bestValue:
                bestValue = nodeValue
                bestNodes = [child]
            elif nodeValue == bestValue:
                bestNodes.append(child)
        return random.choice(bestNodes)

    # 返回最佳子节点的PlanState实例
    def getAction(self, root, bestChild):
        for action, node in root.children.items():
            if node is bestChild:
                return action
