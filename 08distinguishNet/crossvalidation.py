from arguments import get_args
from supervised import supervised

if __name__ == '__main__':
    args = get_args()
    ddpg_trainer = supervised(args)
    ddpg_trainer.pretreatment("./data/runtime.csv")

    for i in range(ddpg_trainer.datasetnumber):
        ddpg_trainer.load_data(i)
        ddpg_trainer.supervised()
        ddpg_trainer.test_network()
        ddpg_trainer.trainList.clear()
        ddpg_trainer.testList.clear()