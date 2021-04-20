import os
import sys
import random
import datetime
import psycopg2

sql_path = "../resource/jobquery/"
plan_file_path="./ovn-plan.txt"

def runSqlPlan():
    file_object=open(plan_file_path)
    file_content=file_object.readlines()
    file_object.close()
    file_output=open("./log.txt",'w')
    search_time=0
    head=" ".join(["query_name", "query_plan", "plan_time1", "plan_time2", "plan_time", "datetime\n"])
    file_output.write(head)
    file_output.flush()
    for line in file_content:
        if len(line.split()) == 1:
            search_time=line
            s=" ".join(["search_time = ",search_time[:-1], "\n"])
            file_output.write(s)
            file_output.flush()
        else:
            query_name=line.split(',')[0].strip()
            query_plan=line.split(',')[1].strip()
            plan_time1=float(line.split(',')[2].strip())

            file_object=open(sql_path+query_name+'.sql')
            sql=file_object.read()
            file_object.close()

            os.system('./dropCache.sh')
            conn = psycopg2.connect(database="imdb", user="imdb",password="imdb", host="localhost", port="5432")
            cur = conn.cursor()

            statement=" ".join(["/*+ Leading(", query_plan,") */","explain", "analyze", sql])
            cur.execute(statement)
            plan_time2=float(cur.fetchall()[-1][-1].split(' ')[-2])
            plan_time=plan_time1+plan_time2
            msg = (query_name + ',' + query_plan + ',' + str(plan_time1) + ',' + str(plan_time2) 
            + ',' + str(plan_time) + ',' + str(datetime.datetime.now()) + "\n")
            file_output.write(msg)
            file_output.flush()
    file_output.close()

if __name__ == "__main__":
    runSqlPlan()
