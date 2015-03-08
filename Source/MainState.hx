package;

import haxe.Http;
import haxe.xml.Fast;

class MainState
{
    private var _subList:Map<String, String>;
    private var _userID:String;

    public function new()
    {
        _userID = getID();
        _subList = getSubList(_userID);
        //printSubList(_subList);
    }

    private function getID():String
    {
        Sys.print("Give userID: ");
        Sys.print("\n");
        return Sys.stdin().readUntil(10);
    }
    
    private function getSubList(id:String):Map<String, String>
    {
        Sys.println("Getting subscriptions. . .");
        var subList:Map<String, String> = new Map<String, String>();
        var subs:Int = 0;

        for (i in 0...1000)
        {
            var xml:Xml = Xml.parse(Http.requestUrl(
                "http://gdata.youtube.com/feeds/api/users/" +
                id + "/subscriptions?v=2&max-results=25&start-index=" +
                Std.string(i * 25 + 1)));

            var newEntries:Int = 0;
            for (i in xml.firstElement().elementsNamed("entry"))
            {
                newEntries++;

                var name:String = "";
                var id:String = "";
                for (j in i.elements())
                {
                    if (j.nodeName == "yt:username") name = j.get("display");
                    if (j.nodeName == "content")
                    {
                        if (j.get("src").indexOf("channel/") >= 0) id = j.get("src").split("channel/")[1];
                        if (j.get("src").indexOf("users/") >= 0) id = j.get("src").split("users/")[1].split("/")[0];
                    }
                }
                subList.set(name, id);
            }

            if (newEntries == 0) break;
        }
        Sys.println("Done, got " + countSubList(subList) + " subscriptions");
        return subList;
    }
    
    private function countSubList(subList:Map<String, String>):Int
    {
        var sum:Int = 0;
        for (i in subList.keys())
        {
            sum++;
        }
        
        return sum;
    }

    private function printSubList(subList:Map<String, String>):Void
    {
        var array:Array<String> = [];
        for (i in subList.keys())
        {
            array.push(i);
        }

        array.sort(function(a,b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
        for (i in array)
        {
            Sys.println(i);
        }
    }
}
