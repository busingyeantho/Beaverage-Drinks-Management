// Import the functions you need from the SDKs you need
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

// TODO: Replace the following with your app's Firebase project configuration
const firebaseConfig = {
  apiKey: "AIzaSyBtzEoIJUOlAJknGzutvXM0AmbXKgJXLv4",
  authDomain: "johnpomb-b85d0.firebaseapp.com",
  projectId: "johnpomb-b85d0",
  storageBucket: "johnpomb-b85d0.firebasestorage.app",
  messagingSenderId: "475791994708",
  appId: "1:475791994708:web:4e0004805e48d60158a2c1",
  measurementId: "G-Q967DMWXMB"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

export { app, auth, db }; 