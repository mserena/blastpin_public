export {};
const fetch = require("node-fetch");
const functions = require("firebase-functions");

exports.checkUrl = functions.https.onCall(async (data : any) => {
    const url = data.url;
    console.log("checkUrl call with url "+url);
    try{
        let options = {
            "redirect": "follow",
            "follow": 20,
        };
        const response = await fetch(url,options);
        console.log("response: "+response.ok+", code: "+response.status);
        return {
            "result": "done",
            "online": response.ok,
            "code": response.status
        };
    } catch(e) {
        console.error("Generic error on checkUrl: "+e);
        return {"result": "error"};
    }
});

exports.getServerTime = functions.https.onCall(async () => {
    const date = new Date();
    return {
        "result": "done",
        "serverTime": date.toISOString(),
    };
});