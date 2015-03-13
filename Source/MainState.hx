package;

import haxe.Http;
import haxe.xml.Fast;

class MainState
{
    private var _sublist:Map<String, String>;
    private var _videoList:Array<Video>;
    private var _userID:String;

    public function new()
    {
        //_userID = getID();
        _userID = "7974z9_BezY-GAjqYja3Eg";
        _sublist = getSublist(_userID);
        _videoList = getVideoList(_sublist);

        Sys.println("Videos: " + _videoList.length);
        for (i in _videoList)
        {
            Sys.println(i.title + " at " + i.uploadTime + "(" + i.date + ")");
        }
    }

    private function getID():String
    {
        Sys.print("Give userID: ");
        return Sys.stdin().readUntil(10);
    }
    
    private function getSublist(id:String):Map<String, String>
    {
        Sys.println("Getting subscriptions. . .");
        var sublist:Map<String, String> = new Map<String, String>();
        var subs:Int = 0;

        for (i in 0...1000)
        {
            var fast:Fast = getFastFromUrl(
                "http://gdata.youtube.com/feeds/api/users/" +
                id + "/subscriptions?v=2&max-results=25&start-index=" +
                Std.string(i * 25 + 1));
            
            var newEntries:Int = 0;
            for (entry in fast.nodes.entry)
            {
                newEntries++;

                var name:String = "";
                var id:String = "";
                for (yt_username in entry.nodes.yt_username) name = yt_username.att.display;
                for (content in entry.nodes.content)
                {
                    if (content.att.src.indexOf("channel/") >= 0) id = content.att.src.split("channel/")[1];
                    if (content.att.src.indexOf("users/") >= 0) id = content.att.src.split("users/")[1].split("/")[0];
                }

                sublist.set(name, id);
            }

            if (newEntries == 0) break;
        }
        Sys.println("Done, got " + countSublist(sublist) + " subscriptions");
        return sublist;
    }

    private function getVideoList(sublist:Map<String, String>):Array<Video>
    {
        var videos:Array<Video> = [];
        
        for (sub in sublist.keys())
        {
            var fast:Fast = getFastFromUrl(
                "http://gdata.youtube.com/feeds/api/users/" +
                sublist.get(sub) +
                "/uploads?orderby=published&max-results=20");

            for (entry in fast.nodes.entry)
            {
                var video:Video = {};
                try
                {
                    for (title in entry.nodes.title) video.title = title.innerData;
                    for (content in entry.nodes.content) video.description = content.innerData;
                    for (published in entry.nodes.published)
                    {
                        var date:Date = Date.fromString(published.innerData.split("T").join(" ").split(".000Z").join(""));
                        video.date = date.toString();
                            
                        video.uploadTime =
                            (date.getFullYear() - 2005) * 31556926 +
                            date.getMonth() * 2629743 +
                            date.getDate() * 86400 +
                            date.getHours() * 3600 +
                            date.getMinutes() * 60 +
                            date.getSeconds();
                    }
                    for (media_group in entry.nodes.media_group)
                    {
                        for (yt_duration in media_group.nodes.yt_duration) video.duration = yt_duration.att.seconds;
                        for (media_player in media_group.nodes.media_player) video.url = "http://" + media_player.att.url.split("//")[1].split("&")[0];
                    }
                    video.author = sub;
                    videos.push(video);
                } catch (unknown:Dynamic) {
                    continue;
                }
            }
        }

        videos.sort(function (v1:Video, v2:Video):Int
            {
                return v1.uploadTime - v2.uploadTime;
            });

        return videos;
    }
    
    private function countSublist(sublist:Map<String, String>):Int
    {
        var sum:Int = 0;
        for (i in sublist.keys())
        {
            sum++;
        }
        
        return sum;
    }

    private function printMap(map:Map<String, String>):Void
    {
        for (i in map.keys())
        {
            Sys.println(i + " => " + map.get(i));
        }
    }

    private function getFastFromUrl(url:String):Fast
    {
        var string:String = Http.requestUrl(url);
        string = string.split(":").join("_");
        var xml:Xml = Xml.parse(string);
        return new Fast(xml.firstElement());
    }

}

typedef Video =
{
    ?title:String,
    ?author:String,
    ?url:String,
    ?date:String,
    ?uploadTime:UInt,
    ?duration:String,
    ?description:String
}

