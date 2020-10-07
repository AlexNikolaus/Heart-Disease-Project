# Heart-Disease-Project

This project involved predicting whether someone has a heart condition or not, while also predicting the severity of the condition (on a scale from 0 - absence of a heart condition, to 4 - very present heart condition). I have tried the random forest and k-NN approaches.
I have also tried a ML model with a binary approach, where 0 is the absence of a heart condition, while 1 is the presence of a heart condition.
The EDA also contains a clustering model using Gower distance (http://links.jstor.org/sici?sici=0006-341X%28197112%2927%3A4%3C857%3AAGCOSA%3E2.0.CO%3B2-3), as this was a mixed dataset.
The dataset is available at https://archive.ics.uci.edu/ml/datasets/heart+Disease, and I've used the same 14 attributes as indicated on the site.

1. #3 (age)
2. #4 (sex)
3. #9 (cp) - chest pain type
-- Value 1: typical angina
-- Value 2: atypical angina
-- Value 3: non-anginal pain
-- Value 4: asymptomatic
4. #10 (trestbps) - resting blood pressure (in mm Hg on admission to the hospital)
5. #12 (chol) - serum cholestoral in mg/dl
6. #16 (fbs) - (fasting blood sugar > 120 mg/dl) (1 = true; 0 = false)
7. #19 (restecg) - resting electrocardiographic results
-- Value 0: normal
-- Value 1: having ST-T wave abnormality (T wave inversions and/or ST elevation or depression of > 0.05 mV)
-- Value 2: showing probable or definite left ventricular hypertrophy by Estes' criteria
8. #32 (thalach) - maximum heart rate achieved
9. #38 (exang) - exercise induced angina (1 = yes; 0 = no)
10. #40 (oldpeak) - ST depression induced by exercise relative to rest
11. #41 (slope) - the slope of the peak exercise ST segment
-- Value 1: upsloping
-- Value 2: flat
-- Value 3: downsloping
12. #44 (ca) - number of major vessels colored by flourosopy
13. #51 (thal)  - 3 = normal; 6 = fixed defect; 7 = reversable defect
14. #58 (num) (the predicted attribute)
