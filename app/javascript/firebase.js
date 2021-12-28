// Using firebase v9 compatibility until firebaseui gets updated to work with
// firebase v9 modules:
import firebase from "@firebase/app-compat"

const googleCloudProject = document.head.querySelector(
  'meta[name="google-cloud-project"]'
).content

const apiKey = document.head.querySelector(
  'meta[name="google-cloud-firebase-api-key"]'
).content

firebase.initializeApp({
  apiKey,
  authDomain: `${googleCloudProject}.firebaseapp.com`
})
