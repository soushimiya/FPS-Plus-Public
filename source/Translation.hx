package;

import json2object.JsonParser;

using StringTools;

class Translation
{
    public static final DEFAULT_LOCALE = "en-US";
    public static var id:String = "en-US";

    public static var data:LocaleData = {assets: [], translations: []};

    public static function set(newLocale:String)
    {
        trace("initalizing translation with " + newLocale);

        if (Utils.exists("assets/locales/" + newLocale + "/data.json") && newLocale != DEFAULT_LOCALE){
            var parser = new JsonParser<LocaleData>();
            data = parser.fromJson(Utils.getText("assets/locales/" + newLocale + "/data.json"), "assets/locales/" + newLocale + "/data.json");
            id = newLocale;
        }
    }

    public static function get(from:String)
    {
        if (data.translations.exists(from))
            return data.translations.get(from);
        else
            return from;
    }
}

typedef LocaleData = {
    var assets:Map<String, String>;
    var translations:Map<String, String>;
}