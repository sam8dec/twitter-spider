TWITTER-SPIDER
==============
Twitter data collection with [Tweepy](http://www.github.com/tweepy/tweepy) in Python. 

Key Features:
- Includes support for starting the spider as an Ubuntu service.
- Spawned during system startup and respawned in the event of a kill.
- Generates JSON tweets on a daily basis in files, &lt;YYYYMMDD&gt;.json **(Note that only a subset of the fields are dumped)**
- Logs info and error in &lt;YYYYMMDD&gt;.json.log

###Required Python libraries

- ####Tweepy
sudo pip install tweepy

- ####ConfigParser
sudo pip install configparser

###Twitter Application

1. Open a web browser and go to http://dev.twitter.com/
2. Click “Sign in” in the top right corner and sign in with your normal Twitter username and password
3. Hover on your username in the top-right corner and click "My Applications"
4. Click the "Create a new application" button
5. Read and accept the terms and conditions – note principally that you agree not to distribute any of the raw tweet data and to delete tweets from your collection if they should be deleted from Twitter in the future.
6. Enter a name, description, and temporary website (e.g. http://coming-soon.com)
7. Read and accept the developer rules of the road, enter the CAPTCHA
8. Click "Create your Twitter application"
9. Scroll to the bottom of the page and click "Create my access token"
10. Wait a minute or two and press your browser's refresh button (or ctrl+r / cmd+r)
11. You should now see new fields labeled "Access token" and "Access token secret" at the bottom of the page.
12. You now have a Twitter application that can act on behalf of your Twitter user to read data from Twitter.

###Updating the Configuration

1. Update the keys, API_KEY, API_SECRET, ACCESS_TOKEN, ACCESS_TOKEN_SECRET in **Config_sample** with the info you received in the previous steps. **Do not enclose the values in quotes**.
2. Create a folder of your choice to dump the tweets. Files (1 per day) will be generated in that folder. Enter the full path in DUMP_LOCATION.
3. Create a folder of your choice to dump logs. Files (1 per day) will be generated in that folder. Enter the full path in LOG_LOCATION.
4. Your thus updated file should look something like:
<br><code>
[TOKENS]
CONSUMER_KEY = AbcDefgHIJKlmnoPQRSTuVWXyZ
CONSUMER_SECRET = ABCdefghijklmnopQrsTuVwXyZ
AUTHORIZATION_TOKEN = 123456789-AbcDefghIjklMNopQRSTuvwXYZ
AUTHORIZATION_SECRET = abcdefGHIJklmnopqRstUVwXyZ<br>
[PARAMETERS]
DUMP_LOCATION = /home/sabanerjee/DSL/twitter/dumps
LOG_LOCATION = /home/sabanerjee/DSL/twitter/dumps/logs
</code><br>

4. Rename **Config_sample** to **Config**.
5. In the **init()** function of **spider**, change the path to the **Config** file appropriately.

Now you are good to start the spider as a user process. Just execute **./spider** and BOOM! However, if you need it as a service which will automatically start up during system start and respawn on kill, please read on.

###Creating the Ubuntu Service

1. You must have root access to execute the steps below.
2. If required, change the user name in **twitterspider.conf** from the default **'hadoop'** to one who is authorized to run the spider. Copy **twitterspider.conf** to /etc/init/.<br><code>sudo cp twitterspider.conf /etc/init </code>
3. Copy **spider** to /usr/bin/.<br><code>sudo cp spider /usr/bin/</code>
4. Start the service:<br><code>sudo service twitterspider start</code> and BOOM!
5. Play around with the service - check the logs, try killing it and see if it restarts.
6. To stop the service:<br><code>sudo service twitterspider stop</code>

###Loading tweets to Hadoop DFS

The script loadDumpToHDFS.sh loads a tweet dump to HDFS. To use it, open the script in your favorite editor and alter the HADOOP_HOME, JAVA_HOME and LOCAL_DUMP_LOC environment variables appropriately. The default folder location used is **Twitter** under the current hadoop user's directory. You can change it by changing the variable, **dumploc**. There are two ways to run the script:

**1. Without any arguments:** The script would in this case look for the previous day's dump and copy it to HDFS and after that delete the local dump.
**2. With date in YYYYMMDD format:** The script will copy the dump of the specified date to HDFS and thereafter delete it. 

You can also schedule a cron job to load the dumps to HDFS every day as tweets get collected. One way to do this is add the following entry to **crontab**:

```
	30 0  * * *   /scratch2/hadoop/Twitter/dumps/loadDumpToHDFS.sh >> /scratch2/hadoop/Twitter/dumps/logs/hdfsdump.log 2>&1
```
This example is from my machine where the script is in the same location as the dump and I log the output of the script too.

After dumping to HDFS, the script also inserts the count of the number of tweets into an HBase Table. The table name is **andy\_tweetcounts** by default. Please change this if you would like to use this feature.

###Counting the number of tweets


The **loadDumpToHDFS.sh** script counts the number of tweets too. In addition, there is a separate script to count the number of tweets collected on a particular day (to find mentions of entities per million, etc). The script linecount.sh does that for you. You need to specify the day in YYYYMMDD format as an argument. By default it takes the previous day. The way to run it is:

```
	./linecount.sh 20140930
```
OR
```
	./linecount.sh
```
The latter processes yesterday's tweets.

