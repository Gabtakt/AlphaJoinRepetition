import torch
import torch.nn as nn
import torch.nn.functional as F


class ValueNet(nn.Module):
    def __init__(self, in_dim, out_dim):
        super(ValueNet, self).__init__()
        self.layer1 = nn.Sequential(
            nn.Conv2d(1, 25, kernel_size=3),
            nn.BatchNorm2d(25),
            nn.ReLU(inplace=True)
        )

        self.layer2 = nn.Sequential(
            nn.MaxPool2d(kernel_size=2, stride=2)
        )

        self.layer3 = nn.Sequential(
            nn.Conv2d(25, 50, kernel_size=3),
            nn.BatchNorm2d(50),
            nn.ReLU(inplace=True)
        )

        self.layer4 = nn.Sequential(
            nn.MaxPool2d(kernel_size=2, stride=2)
        )

        self.fc = nn.Sequential(
            nn.Linear(50 * 5 * 5, 1024),
            nn.ReLU(inplace=True),
            nn.Linear(1024, 128),
            nn.ReLU(inplace=True),
            nn.Linear(128, out_dim)
        )

        self.layer5 = nn.Sequential(
            nn.Linear(72, out_dim),
            nn.ReLU(inplace=True)
        )

        self.layer6 = nn.Sequential(
            nn.Linear(out_dim*2, out_dim),
            nn.ReLU(inplace=True)
        )

    def forward(self, x):
        y = x.narrow(0, 72, 72)
        x = x.narrow(0, 72, 784).reshape(1, 1, 28, 28)
        x = self.layer1(x)
        x = self.layer2(x)
        x = self.layer3(x)
        x = self.layer4(x)
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        x = x.reshape(-1)
        y = self.layer5(y)
        x = self.layer6(torch.cat((x, y), 0))
        return x

    # def __init__(self, in_dim, out_dim):
    #     super(ValueNet, self).__init__()
    #     self.dim = in_dim
    #     self.layer1 = nn.Sequential(nn.Linear(in_dim, 1024), nn.ReLU(True))
    #     self.layer2 = nn.Sequential(nn.Linear(1024, 2048), nn.ReLU(True))
    #     self.layer3 = nn.Sequential(nn.Linear(2048, 512), nn.ReLU(True))
    #     self.layer4 = nn.Sequential(nn.Linear(512, 128), nn.ReLU(True))
    #     self.layer5 = nn.Sequential(nn.Linear(128, 32), nn.ReLU(True))
    #     self.layer6 = nn.Sequential(nn.Linear(32, out_dim))
    #
    # def forward(self, x):
    #     # x = x.reshape(-1, self.dim)
    #     x = self.layer1(x)
    #     x = nn.functional.dropout(x, p=0.5, training=self.training)
    #     x = self.layer2(x)
    #     x = nn.functional.dropout(x, p=0.5, training=self.training)
    #     x = self.layer3(x)
    #     x = nn.functional.dropout(x, p=0.5, training=self.training)
    #     x = self.layer4(x)
    #     x = nn.functional.dropout(x, p=0.5, training=self.training)
    #     x = self.layer5(x)
    #     x = nn.functional.dropout(x, p=0.5, training=self.training)
    #     x = self.layer6(x)
    #     return x
