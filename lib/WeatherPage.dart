import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  List<WeatherData> weatherDataList = [];
  String cityName = '';  // 保存城市名
  WeatherData? todayWeather;
  bool isLoading = true;  // 标志是否正在加载
  var logger = Logger();
  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  // 获取用户位置信息
  Future<Position> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return position;
    } else {
      throw Exception('定位权限未授权');
    }
  }

  // 获取城市信息和 locationId
  Future<String> getCityId(double latitude, double longitude) async {

    String lat = latitude.toStringAsFixed(2);
    String lon = longitude.toStringAsFixed(2);

    final apiKey = 'd33ab0fddb4b4716a7fa483de841a849';
    final url = Uri.parse('https://geoapi.qweather.com/v2/city/lookup?key=$apiKey&location=$lon,$lat');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['code'] == '200' && data['location'] != null && data['location'].isNotEmpty) {
        logger.i("获取城市名称,id成功");
        // 获取城市名称和 locationId
        var city = data['location'][0];
        setState(() {
          cityName = city['name'];  // 存储城市名
        });
        return city['id'];  // 返回 locationId
      } else {
        throw Exception('无法获取城市信息');
      }
    } else {
      throw Exception('无法获取城市信息');
    }
  }

  // 获取天气信息
  Future<Map<String, dynamic>> getWeather(String locationId) async {
    final apiKey = 'd33ab0fddb4b4716a7fa483de841a849';
    final url = Uri.parse('https://devapi.qweather.com/v7/weather/7d?key=$apiKey&location=$locationId');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      logger.i("获取天气信息成功");
      return json.decode(response.body);
    } else {
      throw Exception('无法获取天气信息');
    }
  }
//从缓存中获取天气信息
  Future<bool> _loadCachedWeatherIfValid() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedWeather = prefs.getString('weatherData');
    int? cachedTime = prefs.getInt('cachedTime');

    if (cachedWeather != null && cachedTime != null) {

      DateTime cachedDateTime = DateTime.fromMillisecondsSinceEpoch(cachedTime);
      DateTime now = DateTime.now();


      if (now.difference(cachedDateTime).inMinutes < 120) {
        logger.i("缓存中获取到信息");
        Map<String, dynamic> weatherData = json.decode(cachedWeather);
        setState(() {
          weatherDataList = (weatherData['daily'] as List).map((item) {
            return WeatherData.fromJson(item);
          }).toList();
          todayWeather = weatherDataList[0];
          cityName = weatherData['cityName'];
          isLoading = false;
        });
        return true;
      }else{
        logger.i("缓存过期");
      }
    }
    return false;
  }

  // 保存天气信息到缓存
  Future<void> _cacheWeatherData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    data['cityName'] = cityName;
    prefs.setString('weatherData', json.encode(data));
    prefs.setInt('cachedTime', DateTime.now().millisecondsSinceEpoch);
  }
  // 加载天气信息
  Future<void> _loadWeather() async {
    bool isCachedValid = await _loadCachedWeatherIfValid();
    if (isCachedValid) return; // 如果缓存有效，则直接返回
    try {
      Position position = await getUserLocation();
      // 获取城市的 locationId

      String locationId = await getCityId(position.latitude, position.longitude);
      logger.i("locationid:$locationId");
      // 根据 locationId 获取天气信息
      var weatherData = await getWeather(locationId);
      setState(() {
        // 将返回的数据解析成 WeatherData 列表
        weatherDataList = (weatherData['daily'] as List).map((item) {
          return WeatherData.fromJson(item);
        }).toList();

        // 设置今天的天气
        todayWeather = weatherDataList[0];
        isLoading = false;  // 数据加载完成，停止显示加载圈

      });
      logger.i("装载缓存");
      await _cacheWeatherData(weatherData);
    } catch (e) {
      setState(() {
        weatherDataList = [];
        todayWeather = null;
        isLoading = false;  // 数据加载完成，停止显示加载圈
      });
    }
  }
  String getDayOfWeek(String date) {
    DateTime parsedDate = DateTime.parse(date);
    List<String> weekDays = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"];
    return weekDays[parsedDate.weekday - 1];
  }
  @override
  Widget build(BuildContext context) {
    return Container(

      padding: EdgeInsets.all(20.0),
      child:  isLoading?
      // 显示加载指示器
      Center(child: CircularProgressIndicator()):Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //WeatherBg(weatherType: WeatherType.lightRainy,width: 200,height: 400,),
          if (!isLoading && todayWeather != null)
          // 显示今天的天气信息
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cityName',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '白天天气: ${todayWeather!.textDay}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '最高温度: ${todayWeather!.tempMax}°C',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 20),
                    Text(
                      '最低温度: ${todayWeather!.tempMin}°C',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),

          if (!isLoading && weatherDataList.isNotEmpty)
          // 展示7天的天气信息
            Expanded(
              child: ListView.builder(
                itemCount: weatherDataList.length,
                itemBuilder: (context, index) {

                  String dayText=getDayOfWeek(weatherDataList[index].date);
                  if(index==0){
                    dayText='今天';
                  }else if(index==1){
                    dayText='明天';
                  }

                  return WeatherCard(data: weatherDataList[index], dayText: dayText);
                },
              ),
            ),
        ],
      ),
    );



  }
}

class WeatherData {
  final String date;
  final String textDay;
  final String textNight;
  final String tempMax;
  final String tempMin;
  final String windDirDay;
  final String windDirNight;
  final String windSpeedDay;
  final String windSpeedNight;
  final String humidity;
  final String precip;
  final String pressure;
  final String uvIndex;

  WeatherData({
    required this.date,
    required this.textDay,
    required this.textNight,
    required this.tempMax,
    required this.tempMin,
    required this.windDirDay,
    required this.windDirNight,
    required this.windSpeedDay,
    required this.windSpeedNight,
    required this.humidity,
    required this.precip,
    required this.pressure,
    required this.uvIndex,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      date: json['fxDate'],
      textDay: json['textDay'],
      textNight: json['textNight'],
      tempMax: json['tempMax'],
      tempMin: json['tempMin'],
      windDirDay: json['windDirDay'],
      windDirNight: json['windDirNight'],
      windSpeedDay: json['windSpeedDay'],
      windSpeedNight: json['windSpeedNight'],
      humidity: json['humidity'],
      precip: json['precip'],
      pressure: json['pressure'],
      uvIndex: json['uvIndex'],
    );
  }
}

class WeatherCard extends StatelessWidget {
  final WeatherData data;
  final String dayText;

  WeatherCard({required this.data, required this.dayText});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO( 48, 61, 93,1),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dayText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            Text(
              '${data.textDay}  ${data.tempMin}°C ~ ${data.tempMax}°C',
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
