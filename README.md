

A Flutter-based AI-powered trip planner that leverages Gemini for itinerary generation and Pinecone for semantic memory and caching.


 Setup & Installation
Follow these steps to set up and run the project locally.

 Prerequisites
Ensure you have the following installed:
Flutter SDK (>= 3.10.0)
Dart (bundled with Flutter)
Android Studio / VS Code
Android SDK (API 35 recommended)
Git

A connected Android device or emulator

 Clone the Repository
git clone https://github.com/bonkbeats/Smart-Trip-Planner.git
cd smart_trip_planner

 Install Dependencies
flutter pub get

 Android SDK Setup
Make sure Android SDK API level 35 is installed via Android Studio:
Open Android Studio > SDK Manager
Install API 35 (Upside Down Cake)

 Run the App
To run in debug mode:
flutter run

To build a debug APK:
flutter build apk --debug

To build a release APK:
flutter build apk --release


🔍 Step 1: Query Understanding & Retrieval (Pinecone)
User enters a travel query (e.g., "plan a 3-day trip to Manali").
The query is converted into a vector embedding.
That vector is sent to Pinecone to check if a similar query was answered earlier:
If similarity ≥ 0.95 → Return saved itinerary directly (cached result).
If similarity between 0.90–0.95 → Use as context to generate better response.
Else → Go to Gemini for fresh response.

🤖 Step 2: Response Generation (Gemini API)
If no matching result is found in Pinecone:
The query (and optionally a similar context) is sent to the Gemini AI model.
Gemini returns a structured JSON itinerary.
This response is parsed, displayed in chat UI, and stored for reuse.

📦 Step 3: Save for Future Reuse (Pinecone + Isar)
The final prompt-response pair is:
Saved in Pinecone with its embedding for future similarity matches.
Saved locally using Isar for offline access and chat history.

Create a `.env` file in the project root and add the following keys:

```env
GEMINI_API_KEY=your_gemini_api_key_here
PINECONE_API_KEY=your_pinecone_api_key_here
PINECONE_ENV=your_pinecone_env
PINECONE_INDEX_NAME=your_index_name
PINECONE_URI=https://trip-ntfbatu.svc.aped-4627-b74a.pinecone.io //model for vector embedding
HF_API_KEY=your_huggingface_api_key_here

💡 Note: These keys are required for the app to function. You can generate them from the following platforms:

Gemini API: https://makersuite.google.com/app
Pinecone: https://www.pinecone.io/start/
Hugging Face: https://huggingface.co/settings/tokens

https://lucid.app/lucidchart/4ab0090f-6443-4a60-9487-accab97c986f/edit?viewport_loc=-2692%2C-3751%2C16354%2C7723%2C0_0&invitationId=inv_3c73feb3-cbf9-4e32-876f-73a50c4b80fd


