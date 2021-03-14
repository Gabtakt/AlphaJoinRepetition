import time

from arguments import get_args
from supervised import supervised

if __name__ == '__main__':
    args = get_args()

    ddpg_trainer = supervised(args)

    print("Pretreatment running...")
    start = time.clock()
    ddpg_trainer.pretreatment("./data/t6.sql")
    elapsed = (time.clock() - start)
    print("Pretreatment time used:", elapsed)
