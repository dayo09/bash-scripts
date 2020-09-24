import adb
import config
import run_one

# Read config
config = config.ReadConfig("./python/config.json")
config.print()

# Push model files into adb
adb_runner = adb.AdbRunner("./python/output.txt")
adb_runner.push_files("./resource/<model name>")

# Run One
one_runner = run_one.OneRunner(config)




#adb_runner.run("""ls -all
#echo "hi"
#echo "nice to meet you"
#""", clean = True)

#adb_runner.close()
# run
