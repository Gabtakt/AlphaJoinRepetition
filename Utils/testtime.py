import os
import psycopg2

querypath = '../resource/jobquery'
storagepath = './serviceruntime'


def gettime():
    fileList = os.listdir(querypath)
    fileList.sort(key = lambda x:int(len(x)))

    for queryname in fileList:
        ret_val = os.system('./dropCache.sh')
        print(ret_val)
        # 数据库连接参数
        print("connecting...")
        conn = psycopg2.connect(database="imdb", user="imdb", password="imdb", host="localhost", port="5432")
        cur = conn.cursor()
        print("connect success")
        sqlpath = querypath + "/" + queryname
        file_object = open(sqlpath)
        file_context = file_object.read()
        file_object.close()
        sql = " ".join(["explain", "analyze", file_context])
        cur.execute(sql)
        ret = cur.fetchall()
        time = ret[-1][-1].split(' ')[-2]
        msg = queryname.split('.')[0] + ' ' + time + '\n'
        f = open(storagepath,'a')
        f.write(msg)
        f.close()



if __name__ == '__main__':
    gettime()
