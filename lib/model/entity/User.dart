class User{
  int userId=1;
  String _userName="颗依";
  String _imageUrl="https://md-bucket-1318593463.cos.ap-chengdu.myqcloud.com/img/image-20241101201147857.png";

  String _account ="";
  String _passwd="";

  String getUserName(){
    return this._userName;
  }
  String getImageUrl(){
    return this._imageUrl;
  }
  String getAccount(){
    return this._account;
  }
  String getPasswd(){
    return this._passwd;
  }
  void setAccount(String account){
    this._account=account;
  }
  void setPasswd(String passwd){
    this._passwd=passwd;
  }
}