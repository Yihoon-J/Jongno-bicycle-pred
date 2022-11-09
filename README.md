# Jongno-bicycle-pred
Prediction Model for Jongno-gu district Public Bicycle (따릉이)

## 종로구 따릉이 자전거 예측 수요모델
DScover 22-2 미니프로젝트 C조 결과물

### File description
* Preprocessing.ipynb | 데이터 전처리
* bicycleMovementsInSoul.R.r | 22.06 서울 내 구(區)간 따릉이 이동 내역 데이터 작성
* LSTM_Modeling.ipynb | LSTM 모델링
* XGBoost_Modeling.ipynb | XGBoost 모델링

### Datasets
1. 따릉이 개별 대여 내역
2. 종로구 기상 관측값
3. 종로구 미세먼지 관측값


### Process
1. 따릉이 개별 대여 내역 중 종로구 대여 내역 필터링, 일자별 대여량 집계
2. 기상 및 미세먼지 관측치와 병합하여 데이터셋 생성
3. 결측값 처리 후 이상치 제거, 종속변수 log transformaton
4. XGBoost, LSTM 모델링

### Results
||RMSE|Adjusted R2|
|----:|:----:|:----:|
|XGB|0.54|77%|
|LSTM|0.36|90%|

### Presentation File
![Presentation PDF](https://drive.google.com/file/d/18rh-eSkV2xqK8r0WwZFQn3DdtxMGvi4P/view?usp=share_link)
