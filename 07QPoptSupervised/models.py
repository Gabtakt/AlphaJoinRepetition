import torch
import torch.nn as nn


class ValueNet(nn.Module):
    def __init__(self, in_dim, out_dim):
        super(ValueNet, self).__init__()
        self.dim = in_dim
        self.layer1 = nn.Sequential(nn.Linear(in_dim, 2048), nn.ReLU(True))
        self.layer2 = nn.Sequential(nn.Linear(2048, 512), nn.ReLU(True))
        self.layer3 = nn.Sequential(nn.Linear(512, 128), nn.ReLU(True))
        self.layer4 = nn.Sequential(nn.Linear(128, 32), nn.ReLU(True))
        # # 最后输出层如果用ReLU,会导致很多参数为负值的地方变为0
        # self.layer5 = nn.Sequential(nn.Linear(32, out_dim), nn.LogSoftmax(dim = 0))
        # # self.layer5 = nn.Sequential(nn.Linear(32, out_dim), nn.Softmax(dim = 0))
        self.layer5 = nn.Sequential(nn.Linear(32, 8), nn.ReLU(True))
        self.layer6 = nn.Sequential(nn.Linear(8, 1))
    
    def forward(self, x):
        x = self.layer1(x)
        x = nn.functional.dropout(x, p=0.5, training=self.training)
        x = self.layer2(x)
        x = nn.functional.dropout(x, p=0.5, training=self.training)
        x = self.layer3(x)
        x = nn.functional.dropout(x, p=0.5, training=self.training)
        x = self.layer4(x)
        x = nn.functional.dropout(x, p=0.5, training=self.training)
        x = self.layer5(x)
        x = nn.functional.dropout(x, p=0.2, training=self.training)
        x = self.layer6(x)
        return x.squeeze(-1)
