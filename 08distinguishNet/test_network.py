from arguments import get_args
from supervised import supervised

if __name__ == '__main__':
    args = get_args()

    ddpg_tester = supervised(args)
    ddpg_tester.test_network()

