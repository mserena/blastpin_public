export {};
const admin = require("firebase-admin");
const serviceAccount = require("../../keys/blastpin-ac5eb-firebase-adminsdk-fkd45-0e3e10d45c.json");
if (admin.apps.length === 0) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://blastpin-ac5eb.firebaseio.com",
    });
}
const firestore = admin.firestore();
const functions = require("firebase-functions");

exports.getTags = functions.https.onCall(async (data : any) => {
    console.log("getTags call");
    try{
        let query = firestore.collection("Tags");
        return query.get().then(function(querySnapshot : any) {
            if (!querySnapshot.empty) {
                const tagsList = [] as any;
                querySnapshot.forEach(function(doc : any) {
                    const item = {
                        tagId: doc.id,
                        tagData: doc.data(),
                    };
                    tagsList.push(item);
                });

                console.log("Tags to send: "+querySnapshot.size.toString());
                const response = {
                    "result": "done",
                    "tags": tagsList,
                    "totalBookings": querySnapshot.size.toString(),
                    "date": (new Date()).toISOString(),
                };
                return response;
            } else {
                console.log("No tags defined.");
            }
            return {"result": "done"};
        }).catch(function(error : any) {
            console.log("Error getting documents on getTags:", error);
            return {"result": "error"};
        });
    } catch(e) {
        console.error("Generic error on getTags: "+e);
        return {"result": "error"};
    }
});