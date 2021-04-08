import time
from arguments import get_args
from supervised import supervised

if __name__ == '__main__':
    args = get_args()
    for i in range(10):
        ddpg_trainer = supervised(args)

        print("Pretreatment running...")
        start = time.clock()
        ddpg_trainer.pretreatment("./data/data1")
        elapsed = (time.clock() - start)
        print("Pretreatment time used:", elapsed)

        ddpg_trainer.supervised()
        ddpg_trainer.test_network()
        
