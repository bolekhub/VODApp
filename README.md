# VODApp

![](https://github.com/bolekhub/VODApp/blob/master/VODApp/Resource/capture-2.png)

The project illustrate an approach to handle a push notification having in the payload a list of media items to be downloaded on background. Its not necesary handle all app states (foreground, suspended, or even terminated by the system). Declaring the background modes, push notification its enought. 

>Apps that declare appropriate background modes can use default URL sessions and data tasks, just as if they were in the foreground.`

the push notification must be marked as silent. content-available : 1, heres an example 

```{
    "aps" : {
        "content-available" : 1
    },
    "playlist" : {
        "f3058e6662927f1fcd17840469cfd5f3" : {
            "title" : "Tulips",
            "url" : "https:\/\/my.domain.com\/media\/sample4.mp4"
        },
        "05747156e369eff34cbecb40a2adda6a" : {
            "title" : "Unicorns and horses spining around",
            "url" : "https:\/\/my.domain.com\/media\/sample2.mp4"
        },
        "27da99954cbcf488fb02a145079f3bb9" : {
            "title" : "Big Buck Bunny Movie",
            "subtitle" : "Animated movie yeah",
            "url" : "https:\/\/my.domain.com\/media\/sample5.mp4"
        },
        "f61c3d7f92b199ed7f5812781ccba06f" : {
            "title" : "Superb sunset - Miami Beach 2017",
            "url" : "https:\/\/my.domain.com\/media\/sample1.mp4"
        },
        "9f49077a912f958530060272d6d60d30" : {
            "title" : "Sam Smith, Normani - Dancing With A Stranger",
            "subtitle" : "Official video (Ft. Normani)",
            "url" : "https:\/\/my.domain.com\/media\/sample3.mp4"
        }
    }
}
```

In an effort to comply with apple policy about background task :

>As soon as you finish processing the notification, you must call the block in the handler parameter or your app will be terminated. Your app has up to 30 seconds of wall-clock time to process the notification and call the specified completion handler block. In practice, you should call the handler block as soon as you are done processing the notification. The system tracks the elapsed time, power usage, and data costs for your app’s background downloads. Apps that use significant amounts of power when processing remote notifications may not always be woken up early to process future notifications.

videos that weight more than *20 Mb* will be discarded. If you note the app its taking too long firing the local notification. remove from the josn payload any file beyond mentioned limit and report the bug. :-)

Once al task have been downloaded. the app send a local notification informing the user about new content. 

---
The project include a library to test remote notifications on simulator . See more details how to send the payload [here](https://github.com/acoomans/SimulatorRemoteNotifications)
