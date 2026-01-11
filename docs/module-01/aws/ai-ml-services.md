# Domain 3: AI/ML Services

**CLF-C02 Exam Domain 3, Task 3.7 | 34% of Scored Content**

## Learning Objectives

By the end of this section, you will be able to:

- **Identify AWS artificial intelligence and machine learning services** (Domain 3, Task 3.7)
- Understand AI/ML service categories and use cases
- Compare different AI/ML services for specific requirements
- Understand when to use SageMaker AI vs purpose-built AI services

---

## Overview: AWS AI/ML Services Landscape

AWS provides a comprehensive set of artificial intelligence and machine learning services that enable you to add intelligence to your applications without requiring deep expertise in ML algorithms.

### AI/ML Service Categories

| Category | Services | Purpose |
|----------|----------|---------|
| **ML Platforms** | SageMaker AI | Build, train, deploy custom ML models |
| **Computer Vision** | Rekognition | Image and video analysis |
| **NLP - Text Analysis** | Comprehend | Extract insights from text |
| **NLP - Speech** | Transcribe, Polly, Translate | Speech-to-text, text-to-speech, translation |
| **Document Analysis** | Textract | Extract data from documents |
| **Conversational AI** | Lex | Build chatbots |
| **Search** | Kendra | Intelligent enterprise search |
| **Forecasting** | Forecast | Time-series predictions |

### AI/ML Services for CLF-C02

**Note**: For the CLF-C02 exam, you need to understand **what each service does** and **when to use it**. You do NOT need to know implementation details.

---

## 1. Amazon SageMaker AI

### Overview

**Amazon SageMaker AI** is a fully managed machine learning service that enables data scientists and developers to build, train, and deploy machine learning models quickly.

### Key Capabilities

| Capability | Description |
|------------|-------------|
| **Data Labeling** | Ground truth labeling for training data |
| **Feature Engineering** | Prepare, transform data |
| **Bias Detection** | Detect statistical bias in data and models |
| **AutoML** | Automatically build models |
| **Training** | Managed training infrastructure |
| **Tuning** | Hyperparameter optimization |
| **Hosting** | Deploy models with auto scaling |
| **Monitoring** | Model performance monitoring |
| **Workflows** | ML orchestration pipelines |

### SageMaker AI Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Amazon SageMaker AI                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Label   │  │  Build   │  │  Train   │  │ Deploy   │  │
│  │   Data   │  │  Models  │  │  Models  │  │  Models  │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
│                                                              │
│  Ground Truth → Studio → Notebooks → Endpoints              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### SageMaker AI Use Cases

| Use Case | SageMaker Feature |
|----------|-------------------|
| Custom ML model development | Studio Notebooks |
| Automated model building | SageMaker Autopilot |
| Large-scale training | Managed training jobs |
| Real-time predictions | SageMaker Endpoints |
| Batch predictions | Batch Transform |
| MLOps automation | SageMaker Pipelines |

### SageMaker AI vs Other AI Services

| Scenario | Use SageMaker AI | Use Purpose-Built Service |
|----------|------------------|---------------------------|
| Custom ML model | ✅ Yes | ❌ No |
| Image analysis | Possible, but use Rekognition | ✅ Amazon Rekognition |
| Text-to-speech | Possible, but use Polly | ✅ Amazon Polly |
| Chatbot | Possible, but use Lex | ✅ Amazon Lex |

### Key Features for Exam

- **Fully Managed**: No infrastructure to provision
- **Pay-As-You-Go**: Pay for compute during training/inference
- **Integrated**: Data prep, training, deployment in one service
- **Scalable**: From small to massive ML workloads
- **Notebooks**: Jupyter notebooks for interactive development

---

## 2. Amazon Rekognition

### Overview

**Amazon Rekognition** makes it easy to add image and video analysis to your applications using proven, highly scalable, deep learning technology.

### Key Capabilities

| Capability | Description |
|------------|-------------|
| **Object Detection** | Identify objects (cars, pets, furniture) |
| **Scene Recognition** | Identify scenes (beach, mountain, city) |
| **Face Analysis** | Detect faces, emotions, age range |
| **Face Comparison** | Verify if two faces match |
| **Text Detection** | Extract text from images (OCR) |
| **Celebrity Recognition** | Identify celebrities in images |
| **Unsafe Content** | Detect inappropriate content |
| **Custom Labels** | Train custom models for your objects |

### Rekognition Use Cases

| Use Case | Description |
|----------|-------------|
| **Content Moderation** | Detect inappropriate images/videos |
| **Face Verification** | User authentication (ID verification) |
| **Sentiment Analysis** | Detect emotions from faces |
| **Document Processing** | Extract text from documents |
| **Asset Management** | Search images by content |
| **Security** | Detect people in restricted areas |

### How Rekognition Works

```
┌─────────┐      ┌──────────────┐      ┌──────────┐
│  Image  │ ───▶ │  Amazon     │ ───▶ │  Labels  │
│/Video   │      │ Rekognition │      │/Metadata │
└─────────┘      └──────────────┘      └──────────┘
                       │
                       ├── Objects: ["Person", "Car", "Tree"]
                       ├── Confidence: [98%, 95%, 87%]
                       └── Emotions: ["Happy", "Neutral"]
```

### Storage Integration

- **S3**: Processes images/videos stored in S3
- **Asynchronous**: Publishes results to **Amazon SNS** topic when complete

### Exam Tips

- Rekognition = **Image and Video Analysis**
- Uses **deep learning** for image recognition
- Integrates with **S3** for storage
- Uses **SNS** for async notifications
- Can detect **objects, scenes, faces, text, celebrities**

---

## 3. Amazon Transcribe

### Overview

**Amazon Transcribe** is an automatic speech recognition (ASR) service that makes it easy for developers to add speech-to-text capabilities to their applications.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Speech-to-Text** | Convert audio to text |
| **Deep Learning** | Advanced ASR technology |
| **Multiple Languages** | Support for global languages |
| **Real-Time** | Live transcription |
| **Batch** | Process recorded audio files |
| **Speaker Identification** | Distinguish between speakers |
| **Automatic Punctuation** | Adds punctuation automatically |
| **Custom Vocabulary** | Add domain-specific terms |

### Transcribe Use Cases

| Use Case | Description |
|----------|-------------|
| **Call Transcription** | Customer support calls |
| **Meeting Notes** | Automatic meeting transcription |
| **Captioning** | Video subtitles |
| **Voice Analytics** | Analyze customer conversations |
| **Documentation** | Medical/legal dictation |

### Input/Output Formats

| Input | Output |
|-------|--------|
| Audio files (WAV, MP3, MP4) | Text transcripts |
| Live audio streams | Real-time text |
| Phone recordings | Timestamped transcripts |

### Exam Tips

- Transcribe = **Speech to Text** (Audio → Text)
- Uses **Automatic Speech Recognition (ASR)**
- Can identify **different speakers**
- Supports **real-time** and **batch** processing

---

## 4. Amazon Polly

### Overview

**Amazon Polly** is a Text-to-Speech (TTS) service that turns text into lifelike speech.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Text-to-Speech** | Convert text to audio |
| **Lifelike Voices** | Natural-sounding speech |
| **Multiple Languages** | Support for global languages |
| **SSML Support** | Speech Synthesis Markup Language |
| **Neural TTS** | Advanced deep learning voices |
| **Voice Customization** | Adjust pitch, rate, volume |
| **Newscaster Style** | News reading style |

### Polly Use Cases

| Use Case | Description |
|----------|-------------|
| **Accessibility** | Visual impairment assistance |
| **Voice Assistants** | Alexa-style applications |
| **E-learning** | Course narration |
| **Audiobooks** | Text-to-audio conversion |
| **Gaming** | Character voices |
| **IVR Systems** | Interactive voice response |

### Polly vs Transcribe

| Service | Direction | Use Case |
|---------|-----------|----------|
| **Polly** | Text → Speech | Give your app a voice |
| **Transcribe** | Speech → Text | Convert speech to text |

### Exam Tips

- Polly = **Text to Speech** (Text → Audio)
- Uses **deep learning** for natural speech
- **Neural TTS** = most realistic voices
- Supports **SSML** for speech control

---

## 5. Amazon Translate

### Overview

**Amazon Translate** is a neural machine translation service that delivers fast, high-quality, and affordable language translation.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Neural ML** | Deep learning models |
| **Language Pairs** | 75+ language pairs |
| **Batch Translation** | Translate large volumes |
| **Real-Time** | Live translation |
| **Custom Terminology** | Domain-specific vocabulary |
| **Formality** | Formal/informal tones |

### Translate Use Cases

| Use Case | Description |
|----------|-------------|
| **Website Localization** | Multi-language websites |
| **Document Translation** | Translate documents |
| **Customer Support** | Multi-language support |
| **Content Distribution** | Global content reach |
| **Communication** | Cross-language communication |

### Exam Tips

- Translate = **Language Translation**
- Uses **neural machine translation**
- Supports **75+ language pairs**
- Delivers **fast, high-quality** translation

---

## 6. Amazon Textract

### Overview

**Amazon Textract** automatically extracts printed text, handwriting, and data from any document.

### Key Capabilities

| Capability | Description |
|------------|-------------|
| **OCR** | Optical Character Recognition |
| **Handwriting** | Recognizes printed and handwritten text |
| **Forms Data** | Extract key-value pairs from forms |
| **Table Data** | Extract table structures |
| **Document Analysis** | Understands document context |
| **Identity Documents** | Extract from IDs, passports |
| **Invoices/Receipts** | Understand business documents |
| **Relationships** | Identifies relationships in data |

### Textract vs OCR

| Feature | Traditional OCR | Amazon Textract |
|---------|-----------------|-----------------|
| Text Only | ✅ | ✅ |
| Handwriting | ❌ | ✅ |
| Form Fields | ❌ | ✅ |
| Tables | ❌ | ✅ |
| Context Understanding | ❌ | ✅ |
| Document Type Awareness | ❌ | ✅ |

### Textract Use Cases

| Use Case | Description |
|----------|-------------|
| **Invoice Processing** | Extract line items, totals |
| **Form Automation** | Process application forms |
| **Document Search** | Search within scanned PDFs |
| **Compliance** | KYC, identity verification |
| **Data Entry** | Automate manual data entry |
| **Receipt Processing** | Expense management |

### Supported Document Formats

| Format | Examples |
|--------|----------|
| **Images** | PNG, JPG, TIFF |
| **PDFs** | Scanned and native PDF |
| **Forms** | Tax forms, applications |
| **Tables** | Financial statements, reports |

### Exam Tips

- Textract = **Document Text and Data Extraction**
- Goes beyond **traditional OCR**
- Extracts **forms, tables, handwriting**
- Understands **document context** (e.g., knows what to extract from receipts)
- Uses **AI/ML** for intelligent extraction

---

## 7. Amazon Comprehend

### Overview

**Amazon Comprehend** is a natural language processing (NLP) service that uses machine learning to uncover insights in text.

### Key Capabilities

| Capability | Description |
|------------|-------------|
| **Sentiment Analysis** | Detect positive, negative, neutral, mixed |
| **Key Phrase Extraction** | Find important phrases |
| **Entity Recognition** | Identify people, places, dates, quantities |
| **Topic Modeling** | Discover topics in document collections |
| **Language Detection** | Identify document language |
| **PII Detection** | Detect personally identifiable information |
| **Syntax Analysis** | Parse sentence structure |

### Comprehend Use Cases

| Use Case | Description |
|----------|-------------|
| **Customer Feedback Analysis** | Understand customer sentiment |
| **Document Categorization** | Auto-categorize documents |
| **Social Media Monitoring** | Track brand sentiment |
| **Compliance** | Detect PII in documents |
| **Knowledge Discovery** | Find topics in large document sets |
| **Content Moderation** | Detect inappropriate content |

### Comprehend vs Textract

| Service | Input | Output |
|---------|-------|--------|
| **Comprehend** | Text (already digital) | Insights (sentiment, entities, topics) |
| **Textract** | Scanned documents/images | Extracted text + data |

### Exam Tips

- Comprehend = **NLP Service for Text Analysis**
- **Natural Language Processing** (NLP)
- Extracts **sentiment, entities, key phrases, topics**
- Works on **text data** (not images like Textract)
- Can detect **PII** for compliance

---

## 8. Amazon Lex

### Overview

**Amazon Lex** is a service for building conversational interfaces into any application using voice and text.

### Key Capabilities

| Capability | Description |
|------------|-------------|
| **Chatbots** | Build conversational bots |
| **Voice & Text** | Both modalities supported |
| **ASR & TTS** | Speech recognition and synthesis |
| **Intent Recognition** | Understand user intent |
| **Slot Filling** | Collect required information |
| **Context Management** | Maintain conversation context |
| **Fulfillment** | Integrate with AWS Lambda |

### Lex Components

```
┌─────────────────────────────────────────────────────────────┐
│                       Amazon Lex                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User Input ──▶ Intent Recognition ──▶ Slot Filling          │
│                      │                    │                   │
│                      ▼                    ▼                   │
│              Dialog Management ──▶ Fulfillment (Lambda)       │
│                      │                                       │
│                      ▼                                       │
│                  Response                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Lex Use Cases

| Use Case | Description |
|----------|-------------|
| **Customer Service Bots** | Automated support |
| **Order Taking** | Food delivery, retail |
| **Booking Systems** | Hotel, flight reservations |
| **Information Retrieval** | FAQ bots |
| **Productivity** | Schedule management |

### Lex Architecture

| Component | Description |
|-----------|-------------|
| **Intent** | What the user wants to do |
| **Utterance** | What user says/types |
| **Slot** | Data needed to fulfill intent |
| **Fulfillment** | Lambda function to complete action |
| **Prompt** | Question to get slot value |

### Exam Tips

- Lex = **Conversational AI for Chatbots**
- Uses **same technology as Alexa**
- Supports **voice and text**
- **ASR** (speech recognition) + **TTS** (text-to-speech)
- Uses **Lambda** for backend logic
- **Intents** = user goals, **Slots** = parameters

---

## 9. Amazon Kendra

### Overview

**Amazon Kendra** is an intelligent search service powered by machine learning.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Semantic Search** | Understands meaning, not just keywords |
| **Natural Language Queries** | Ask questions in natural language |
| **Multiple Data Sources** | Search across repositories |
| **Document Indexing** | Automatic indexing and updates |
| **Faceted Search** | Filter by attributes |
| **Answer Extraction** | Extracts specific answers |
| **Query Suggestions** | Auto-complete suggestions |

### Kendra Use Cases

| Use Case | Description |
|----------|-------------|
| **Enterprise Search** | Search internal documents |
| **Knowledge Base** | FAQ, documentation search |
| **Research** | Legal, medical, financial research |
| **Customer Support** | Find answers for support agents |
| **Compliance** | Search policies, procedures |

### Traditional Search vs Kendra

| Feature | Traditional Search | Amazon Kendra |
|---------|-------------------|----------------|
| **Keyword Matching** | ✅ | ✅ |
| **Semantic Understanding** | ❌ | ✅ |
| **Natural Language** | ❌ | ✅ |
| **Answer Extraction** | ❌ | ✅ |
| **Learning** | ❌ | ✅ |

### Exam Tips

- Kendra = **Intelligent Enterprise Search**
- Uses **ML for semantic search**
- Understands **natural language queries**
- Goes beyond **keyword matching**
- Can **extract specific answers** from documents

---

## 10. Amazon Forecast

### Overview

**Amazon Forecast** is a fully managed service for time-series forecasting.

### Key Characteristics

| Feature | Description |
|---------|-------------|
| **Time-Series** | Business metrics forecasting |
| **ML-Based** | Uses machine learning algorithms |
| **Automatic** | Auto-selects best algorithm |
| **Explainability** | Explains forecast drivers |
| **Item-Level** | Forecast per product/location |

### Forecast Use Cases

| Use Case | Description |
|----------|-------------|
| **Demand Planning** | Product demand forecasting |
| **Inventory** | Stock optimization |
| **Resource Planning** | Staffing, capacity planning |
| **Financial** | Revenue forecasting |

### Exam Tips

- Forecast = **Time-Series Forecasting Service**
- Uses **ML for predictions**
- For **business metrics analysis**
- Used for **demand, inventory, financial** forecasting

---

## 11. Service Comparison and Selection

### AI/ML Services Decision Tree

```
┌─────────────────────────────────────────────────────────────┐
│                  Choose AI/ML Service                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  What type of data?                                          │
│    ├─ Images/Videos ──▶ Amazon Rekognition                  │
│    ├─ Text (Speech) ────▶ Amazon Transcribe (Speech→Text)    │
│    │                     Amazon Polly (Text→Speech)          │
│    ├─ Text (Document) ─▶ Amazon Textract                    │
│    ├─ Text (Digital) ──▶ Amazon Comprehend (NLP)            │
│    │                     Amazon Lex (Chatbots)              │
│    ├─ Documents Search ─▶ Amazon Kendra                      │
│    ├─ Time-Series ──────▶ Amazon Forecast                   │
│    └─ Custom ML Model ─▶ Amazon SageMaker AI                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Service Quick Reference

| Task | Service |
|------|---------|
| **Identify objects in images** | Amazon Rekognition |
| **Detect faces/emotions** | Amazon Rekognition |
| **Convert speech to text** | Amazon Transcribe |
| **Convert text to speech** | Amazon Polly |
| **Translate languages** | Amazon Translate |
| **Extract text from documents** | Amazon Textract |
| **Analyze text sentiment** | Amazon Comprehend |
| **Build chatbot** | Amazon Lex |
| **Enterprise search** | Amazon Kendra |
| **Forecast metrics** | Amazon Forecast |
| **Build custom ML models** | Amazon SageMaker AI |

---

## 12. Generative AI and Foundation Models (2026 Updates)

### Amazon Bedrock

**Amazon Bedrock** is a fully managed service that makes foundation models (FMs) from leading AI companies available through an API.

**Note**: For CLF-C02, you only need to know Bedrock exists as a **generative AI service**. Details are for advanced certifications.

| Feature | Description |
|---------|-------------|
| **Foundation Models** | Access to leading AI company FMs |
| **Serverless** | No infrastructure to manage |
| **API-Based** | Simple API integration |
| **Security** | Data privacy and security |

### Bedrock Model Providers

| Provider | Models |
|----------|--------|
| **AI21 Labs** | Jurassic |
| **Anthropic** | Claude |
| **Cohere** | Command |
| **Meta** | Llama |
| **Stability AI** | Stable Diffusion |
| **Amazon** | Titan (Text, Embeddings) |

### Generative AI Use Cases

| Use Case | Service |
|----------|---------|
| **Text Generation** | Bedrock (Titan, Claude) |
| **Image Generation** | Bedrock (Stable Diffusion) |
| **Chatbots** | Bedrock + Lex |
| **Search** | Kendra + Bedrock |
| **Code Generation** | Bedrock (Code Llama) |

---

## Exam Tips - AI/ML Services

### High-Yield Topics

1. **Service Purposes**:
   - **SageMaker AI** = Build custom ML models
   - **Rekognition** = Image/video analysis
   - **Transcribe** = Speech to text
   - **Polly** = Text to speech
   - **Translate** = Language translation
   - **Textract** = Document text/data extraction
   - **Comprehend** = NLP text analysis
   - **Lex** = Chatbots
   - **Kendra** = Intelligent search
   - **Forecast** = Time-series forecasting

2. **Key Distinctions**:
   - **Polly** vs **Transcribe** = Text→Speech vs Speech→Text
   - **Textract** vs **Comprehend** = Document extraction vs Text analysis
   - **Rekognition** = Images/Videos only
   - **SageMaker AI** vs others = Custom models vs purpose-built services

3. **Integrations**:
   - **S3** = Storage for Rekognition, Textract
   - **SNS** = Async notifications (Rekognition)
   - **Lambda** = Backend logic (Lex)

4. **2026 Update**:
   - **Bedrock** = Generative AI foundation models
   - **Titan**, **Claude**, **Llama**, **Stable Diffusion**

## Additional Resources

### DigitalCloud Training Cheat Sheets
- [AWS Machine Learning Services Cheat Sheet](https://digitalcloud.training/aws-machine-learning/) - Comprehensive AI/ML services reference for exam prep

### Official AWS Documentation
- [Amazon SageMaker AI](https://aws.amazon.com/sagemaker/)
- [Amazon Rekognition](https://aws.amazon.com/rekognition/)
- [Amazon Transcribe](https://aws.amazon.com/transcribe/)
- [Amazon Polly](https://aws.amazon.com/polly/)
- [Amazon Translate](https://aws.amazon.com/translate/)
- [Amazon Textract](https://aws.amazon.com/textract/)
- [Amazon Comprehend](https://aws.amazon.com/comprehend/)
- [Amazon Lex](https://aws.amazon.com/lex/)
- [Amazon Kendra](https://aws.amazon.com/kendra/)
- [Amazon Forecast](https://aws.amazon.com/forecast/)
- [Amazon Bedrock (Generative AI)](https://aws.amazon.com/bedrock/)

### Practice Resources
- [AWS AI/ML Services Overview](https://aws.amazon.com/machine-learning/)
- [Choosing an AWS ML Service](https://docs.aws.amazon.com/decision-guides/latest/machine-learning-on-aws-how-to-choose/guide.html)
- [AWS AI/ML Blog](https://aws.amazon.com/blogs/machine-learning/)

---

**Previous**: [Analytics Services](analytics-services.md)
