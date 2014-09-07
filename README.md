TWITTER-SPIDER
==============
Twitter data collection with [Tweepy](http://www.github.com/tweepy/tweepy) in Python. 

Key Features:
- Includes support for starting the spider as an Ubuntu service.
- Spawned during system startup and respawned in the event of a kill.
- Generates JSON tweets on a daily basis in files, &lt;YYYYMMDD&gt;.json
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

1. Update the keys, CONSUMER_KEY, CONSUMER_SECRET, AUTHORIZATION_TOKEN, AUTHORIZATION_SECRET in **Config_sample** with the info you received in the previous steps. **Do not enclose the values in quotes**.
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
2. Copy **twitterspider.conf** to /usr/init/.<br><code>sudo cp twitterspider.conf /usr/init </code>
3. Copy **spider** to /usr/bin/.<br><code>sudo cp spider /usr/bin/</code>
4. Start the service:<br><code>sudo service twitterspider start</code> and BOOM!
5. Play around with the service - check the logs, try killing it and see if it restarts.
6. To stop the service:<br><code>sudo service twitterspider stop</code>

