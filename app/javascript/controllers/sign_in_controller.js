import { Controller } from "@hotwired/stimulus"

// Using firebase v9 compatibility until firebaseui gets updated to work with
// firebase v9 modules:
import firebase from "@firebase/app-compat"
import "@firebase/auth-compat"
import * as firebaseui from "firebaseui"

const signInOptions = [
  { provider: firebase.auth.EmailAuthProvider.PROVIDER_ID }
]

// Connects to data-controller="sign-in"
export default class extends Controller {
  connect() {
    const firebaseAuth = firebase.auth()
    const firebaseAuthUI = new firebaseui.auth.AuthUI(firebaseAuth)

    firebaseAuthUI.start("#auth-container", { signInOptions })
  }
}
