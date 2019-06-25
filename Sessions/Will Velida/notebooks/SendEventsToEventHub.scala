// Databricks notebook source
import java.util._
import scala.collection.JavaConverters._
import com.microsoft.azure.eventhubs._
import java.util.concurrent._    
import twitter4j._
import twitter4j.TwitterFactory
import twitter4j.Twitter
import twitter4j.conf.ConfigurationBuilder

val namespaceName = "Endpoint=sb://velidaeventhub.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=dlujvfBsQcJX92LMb+hwEGyAQizS2zU7Lz9jnEQ4r6c="
val eventHubName = "velidatwittereventhub"
val sasKeyName = "SendListen"
val sasKey = "/a8tUcvLk4C4YR4l6g83a/S2NfJfl8DlkdPhdDhGeIM="
val connStr = new ConnectionStringBuilder()
                .setNamespaceName(namespaceName)
                .setEventHubName(eventHubName)
                .setSasKeyName(sasKeyName)
                .setSasKey(sasKey)

val twitterConsumerKey = "BfL3xk2MvRcJOOhWjNWCMpjBe"
val twitterConsumerSecret = "qbjVy17E6eT8tRIK4LnZ5w2y2BIvZFuhtLOT3Hy04VPWnBIY11"
val twitterOauthAccessToken = "198597597-cC4Hqh6t9R60qzD7Q6CXvTB1torVjwIzPAtBAweN"
val twitterOauthTokenSecret = "Jv75jwfB75Eb06bLopkiS5OhAJr4DNXiNetHis5SqUfiY"
val pool = Executors.newFixedThreadPool(1)
val eventHubClient = EventHubClient.create(connStr.toString(), pool)

val cb = new ConfigurationBuilder()
cb.setDebugEnabled(true)
   .setOAuthConsumerKey(twitterConsumerKey)
   .setOAuthConsumerSecret(twitterConsumerSecret)
   .setOAuthAccessToken(twitterOauthAccessToken)
   .setOAuthAccessTokenSecret(twitterOauthTokenSecret)

val twitterFactory = new TwitterFactory(cb.build())
val twitter = twitterFactory.getInstance()

def sendEvent(message: String) = {
   val messageData = EventData.create(message.getBytes("UTF-8"))
   eventHubClient.get().send(messageData)
   System.out.println("Sent event: " + message + "\n")
}

val query = new Query(" #Databricks ")
query.setCount(100)
query.lang("en")

var finished = false

while (!finished) {
    val result = twitter.search(query)
    val statuses = result.getTweets()
    var lowestStatusId = Long.MaxValue
    for (status <- statuses.asScala) {
      if(!status.isRetweet()){
          sendEvent(status.getText())
      }
      lowestStatusId = Math.min(status.getId(), lowestStatusId)
      Thread.sleep(2000)
    }
   query.setMaxId(lowestStatusId - 1)
}

 // Closing connection to the Event Hub
 eventHubClient.get().close()

// COMMAND ----------

