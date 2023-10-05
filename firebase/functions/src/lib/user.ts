export {};
const admin = require("firebase-admin");
const serviceAccount = require("../../keys/blastpin-ac5eb-firebase-adminsdk-fkd45-0e3e10d45c.json");
if (admin.apps.length === 0) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://blastpin-ac5eb.firebaseio.com",
    });
}
const authentification = admin.auth();
const functions = require("firebase-functions");

exports.getUserAuthToken = functions.https.onCall(async (data : any) => {
    const email = data.email;
    const name = data.name;
    console.log("getUserAuthToken call with "+email+" and name "+name);
    try{
        var authToken;
        await authentification.getUserByEmail(email).then(async (user : any) => { 
            console.log("user with uid "+user.uid+" exists!");
            authToken = await generateUserAuthToken(user);
        }).catch(async (error : any) => { 
            if (error.code === 'auth/user-not-found') {
                console.log("user not exists!");
                var newUser = await authentification.createUser({
                    email: email,
                    displayName: name,
                    emailVerified: true,
                    disabled: false,
                }).catch((error : any) => {
                    console.error('Error creating new user:'+error);
                    return {"result": "error"};
                });
                console.log("user with id "+newUser.uid+" created!");
                authToken = await generateUserAuthToken(newUser);
            }
        });
        console.log("auth token created for user: "+authToken);
        return {
            "result": "done",
            "authToken": authToken,
        };
    } catch(e) {
        console.error("Generic error on getUserAuthToken: "+e);
        return {"result": "error"};
    }
});

async function generateUserAuthToken(user : any) {
    return admin.auth().createCustomToken(user.uid).then((customToken : any) => {
        return customToken;
    }).catch((error : any) => {
        console.error("Generic error on generateUserAuthToken: "+error);
        return undefined;
    });
}