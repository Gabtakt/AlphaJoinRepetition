from arguments import get_args
from supervised import supervised

if __name__ == '__main__':
    args = get_args()

    ddpg_trainer = supervised(args)
    # ddpg_trainer.pretreatment("./data/runtime.csv")
    ddpg_trainer.load_data(0)
    ddpg_trainer.printdata()

