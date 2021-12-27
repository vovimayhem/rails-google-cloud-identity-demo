# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'

pin 'firebaseui', to: 'https://ga.jspm.io/npm:firebaseui@6.0.0/dist/esm.js'
pin '@firebase/app', to: 'https://ga.jspm.io/npm:@firebase/app@0.7.11/dist/esm/index.esm2017.js'
pin '@firebase/app-compat', to: 'https://ga.jspm.io/npm:@firebase/app-compat@0.1.12/dist/esm/index.esm2017.js'
pin '@firebase/auth-compat', to: 'https://ga.jspm.io/npm:@firebase/auth-compat@0.2.4/dist/index.esm2017.js'
pin '@firebase/auth/internal', to: 'https://ga.jspm.io/npm:@firebase/auth@0.19.4/dist/esm2017/internal.js'
pin '@firebase/component', to: 'https://ga.jspm.io/npm:@firebase/component@0.5.9/dist/esm/index.esm2017.js'
pin '@firebase/logger', to: 'https://ga.jspm.io/npm:@firebase/logger@0.3.2/dist/esm/index.esm2017.js'
pin '@firebase/util', to: 'https://ga.jspm.io/npm:@firebase/util@1.4.2/dist/index.esm2017.js'
pin 'dialog-polyfill', to: 'https://ga.jspm.io/npm:dialog-polyfill@0.4.10/dialog-polyfill.js'
pin 'firebase/compat/app', to: 'https://ga.jspm.io/npm:firebase@9.6.1/compat/app/dist/index.esm.js'
pin 'firebase/compat/auth', to: 'https://ga.jspm.io/npm:firebase@9.6.1/compat/auth/dist/index.esm.js'
pin 'material-design-lite/src/button/button', to: 'https://ga.jspm.io/npm:material-design-lite@1.3.0/src/button/button.js'
pin 'material-design-lite/src/mdlComponentHandler', to: 'https://ga.jspm.io/npm:material-design-lite@1.3.0/src/mdlComponentHandler.js'
pin 'material-design-lite/src/progress/progress', to: 'https://ga.jspm.io/npm:material-design-lite@1.3.0/src/progress/progress.js'
pin 'material-design-lite/src/spinner/spinner', to: 'https://ga.jspm.io/npm:material-design-lite@1.3.0/src/spinner/spinner.js'
pin 'material-design-lite/src/textfield/textfield', to: 'https://ga.jspm.io/npm:material-design-lite@1.3.0/src/textfield/textfield.js'
pin 'tslib', to: 'https://ga.jspm.io/npm:tslib@2.3.1/tslib.es6.js'
