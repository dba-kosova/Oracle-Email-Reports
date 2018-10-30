from shutil import copyfile
from pathlib import Path

def make_sql_file(source, filename, sql):

    home_path = Path(__file__).parents[1].joinpath('sql')
    new_file = str(home_path.joinpath(filename))
    old_file = str(home_path.joinpath(source))
   
    copyfile(old_file, new_file)
   
    # get contents of sql file
    f = open(new_file,"r")
    contents = f.readlines()
    f.close()

    # add new stuff to the end of it
    contents.insert(sum(1 for line in contents)-1,sql + "\n")

    contents = "".join(contents)

    # send stuff back to file
    f = open(new_file, "w")
    f.write(contents)
    f.close()