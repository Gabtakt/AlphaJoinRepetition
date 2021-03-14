from arguments import get_args
from supervised import supervised

if __name__ == '__main__':
    args = get_args()

    ddpg_tester = supervised(args)
    ddpg_tester.test_network()

    # 测试对于蒙特卡洛选择出的hint顺序价值网络给出的是什么样的判断
    file = open("./hint-12.txt")
    count = 0
    while 0:
        lines = file.readlines(100000)
        if not lines:
            break
        for line in lines:
            queryName = line.split(",")[0].strip()
            hint = line.split(",")[1].strip()
            if queryName == "29c":
                print(int(count / 113) + 1, " ", queryName, end="  ")
                ddpg_tester.test_hintcost(queryName, hint)
            count += 1

    file.close()
