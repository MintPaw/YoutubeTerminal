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
        //_videoList = getVideoList(_sublist);
        //Sys.println(_sublist.toString());
        printMap(_sublist);
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
            var video:Video = {};

            var xml:Xml = Xml.parse(Http.requestUrl(
                "http://gdata.youtube.com/feeds/api/users/" +
                sublist.get(sub) +
                "/uploads?orderby=published&max-results=20"));

            var fast:Fast = new Fast(xml.firstElement());
            
            for (entry in fast.nodes.entry)
            {
                for (title in entry.nodes.title) video.title = title.innerData;
                for (content in entry.nodes.content) video.description = content.innerData;
                /*for (media:group in entry.nodes.media:group)
                {
                    for (yt-duration in media-group.yt-duration) video.duration = yt-duration.innerData;
                }*/
                video.author = sub;
            }
        }

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
    ?duration:String,
    ?description:String
}

