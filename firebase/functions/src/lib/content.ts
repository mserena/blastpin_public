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
const generalBucket = 'gs://blastpin-ac5eb.appspot.com';
const storageBucket = admin.storage().bucket(generalBucket);

const enum ContentBlastPinStatus{
    creating =  "creating",   //When user is on creation process
    uploading = "uploading",  //When content is on upload process
    updating =  "updating",   //When content is on update process
    review =    "review",     //When content is on review
    published = "published",  //Content published
    rejected =  "rejected",   //Content can't be published
    deleted =   "deleted",    //Content is deleted
    error =     "error"       //Error on upload process
}

exports.uploadContentInfo = functions.https.onCall(async (data : any) => {
    try{
        const userId = data.userId;
        const type = data.type;
        const status = ContentBlastPinStatus.uploading;
        const location = JSON.parse(data.location);
        const when = JSON.parse(data.datetime);
        const languages = JSON.parse(data.languages) as Map<string,Map<string,string>>;
        const mainTag = data.mainTag;
        const extraTags = JSON.parse(data.extraTags) as string[];
        const socialLinks = JSON.parse(data.socialLinks) as Map<string,string>;
        const ticket = JSON.parse(data.ticket) as Map<string,string>;
        const creationDate = new Date();
        
        console.log("uploadContentInfo call with userId: "+userId);
        console.log("type = "+type);
        console.log("status = "+status);
        console.log("languages = "+Object.keys(languages));
        console.log("when = "+Object.entries(when));
        console.log("locationString = "+location.locationString);
        console.log("locationShortString = "+location.shortLocationString);
        console.log("googleId = "+location.googleId);
        console.log("location = latitude: "+location.location_latitude+", longitude: "+location.location_longitude);
        console.log("mainTag = "+mainTag);
        console.log("extraTags = "+extraTags.toString());
        console.log("socialLinks = "+Object.entries(socialLinks));
        console.log("ticket = "+Object.entries(ticket));
        console.log("creationDate = "+creationDate.toISOString());
    
        return firestore.collection("Content").add({
            userId: userId,
            type: type,
            status: status,
            languages: languages,
            when: when,
            location: location,
            mainTag: mainTag,
            extraTags: extraTags,
            socialLinks: socialLinks,
            ticket: ticket,
            creationDate: creationDate,
        })
        .then(async function(docRef : any){
            console.log("Content created with id: ", docRef.id);
            return {
                "result" : "done",
                "id" :  docRef.id,
                "status" : status
            }; 
        }).catch(function(error : any) {
            console.error("Error uploading content: ", error);
            return {"result" : "error"};
        });
    } catch(e) {
        console.error("Generic error on uploadContentInfo: "+e);
        return {"result": "error"};
    }
});

exports.uploadContentMedia = functions.https.onCall(async (data : any) => {
    try{
        const contentId = data.contentId;
        const userId = data.userId; 
        const status = ContentBlastPinStatus.review;
        const mediaUrls = JSON.parse(data.mediaUrls);
        
        console.log("uploadContentMedia call with contentId: "+contentId+" and userId: "+userId);
        console.log("status = "+status);
        console.log("mediaUrls = "+mediaUrls.toString());

        return firestore.collection("Content").doc(contentId).get().then(async function(doc : any) {
            if (doc.exists && doc.data().userId === userId) {
                return firestore.collection("Content").doc(contentId).update({
                    mediaUrls : mediaUrls,
                    status : status,
                }).then( function (){
                    console.log("Content updated");
                    return {
                        "result" : "done",
                        "status" : status
                    }; 
                }).catch(function(error : any) {
                    console.error("Error on update content: ", error);
                    return {'result' : 'error'};
                });
            } else {
                console.log("No such document or user isn't the owner!");
                return {'result' : 'error'};
            }
        }).catch(function(error : any) {
            console.log("Error getting document:", error);
            return {'result' : 'error'};
        });
    } catch(e) {
        console.error("Generic error on uploadContentMedia: "+e);
        return {"result": "error"};
    }
});

exports.deleteContent = functions.https.onCall(async (data : any) => {
    try{
        const contentId = data.contentId;
        const userId = data.userId; 
        console.log("deleteContent call with userId: "+userId+" and contentId: "+contentId);

        return firestore.collection("Content").doc(contentId).get().then(async function(doc : any) {
            if (doc.exists && doc.data().userId === userId) {
                return firestore.collection("Content").doc(contentId).delete().then(function() {
                    console.log("Document successfully deleted!");
                    return {'result' : 'done'};   
                }).catch(function(error : any) {
                    console.log("Error getting document:", error);
                    return {'result' : 'error'};
                });
            } else {
                console.log("No such document or user isn't the owner!");
                return {'result' : 'error'};
            }
        }).catch(function(error : any) {
            console.log("Error getting document:", error);
            return {'result' : 'error'};
        });
    } catch(e) {
        console.error("Generic error on deleteContent: "+e);
        return {"result": "error"};
    }
});

exports.onDeleteContent = functions.firestore.document('Content/{docId}').onDelete(async (snap : any, context : any) => {
    try{
        const deletedContentId = snap.id;
        console.log("onDelete call with contentId: ", deletedContentId);
        await storageBucket.deleteFiles({
            prefix: `Content/${deletedContentId}`,
        });
        return Promise.resolve(true);
    } catch(e) {
        console.error("Generic error on onDeleteContent: "+e);
    }
    return Promise.resolve(false);
});