from arguments import get_args
from supervised import supervised

if __name__ == '__main__':
    args = get_args()

    ddpg_trainer = supervised(args)
    ddpg_trainer.supervised()
    ddpg_trainer.test_network()
