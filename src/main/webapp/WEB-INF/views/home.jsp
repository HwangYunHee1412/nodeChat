<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
 
<!DOCTYPE html>
<html>
<head>
    <title>Socket.IO chat</title>
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      body { font: 13px Helvetica, Arial; }
      form { background: #000; padding: 3px; position: fixed; bottom: 0; width: 100%; }
      form input { border: 0; padding: 10px; width: 90%; margin-right: .5%; }
      form button { width: 9%; background: rgb(130, 224, 255); border: none; padding: 10px; }
      .pages { height: 100%; margin: 0; padding: 0; width: 100%;}
      .page { height: 100%; position: absolute; width: 100%;}
      .login.page .form{
        height: 100px; margin-top: -100px; position: absolute;
        text-align: center; top: 50%; width: 100%;
      }
      .login.page {
        background-color: WHITE;
      }
      .chatArea {width:100%;}
      #messagesTable {width:70%;}
      #userTable {width:30%; background-color: grey}
      #users #messages { list-style-type: none; margin: 0; padding: 0;}
      #messages li { padding: 5px 10px; }
      #messages li:nth-child(odd) { background: #eee; }

    </style>
  </head>
  <body>
    <ul class="pages">
      <li class = "chat page">
        <div class="userList">
          <h2>현재 접속자</h2>
          <ul id="userList"></ul>
        </div>

        <hr>
        <ul id="messages"></ul>
        <form>
          <input id="m" autocomplete="off" /><button>Send</button>
        </form>
      </li>

      <li class="login page">
        <div class="form">
            <button onclick="calculate()">notify Chrome</button>  <script type="text/javascript">
                  window.onload = function () {
                      if (window.Notification) {
                          Notification.requestPermission();
                      }
                  }

                  function calculate() {
                      setTimeout(function () {
                          notify();
                      }, 5000);
                  }

                  function notify() {
                      if (Notification.permission !== 'granted') {
                          alert('notification is disabled');
                      }
                      else {
                          var notification = new Notification('Notification title', {
                              icon: 'http://cdn.sstatic.net/stackexchange/img/logos/so/so-icon.png',
                              body: 'Notification text',
                          });

                          notification.onclick = function () {
                              window.open('http://google.com');
                          };
                      }
                  }
              </script>
          <h3 class="title">별명을 입력해 주세요!<br></h3>
          <input class="usernameInput" type="text" />
        </div>
      </li>
    </ul>

    <script src="http://localhost:3000/socket.io/socket.io.js"></script>
    <script src="http://code.jquery.com/jquery-1.11.1.js"></script>
    <script>

      var COLORS = [
        '#e21400', '#91580f', '#f8a700', '#f78b00',
        '#58dc00', '#287b00', '#a8f07a', '#4ae8c4',
        '#3b88eb', '#3824aa', '#a700ff', '#d300e7'
      ];

      var $window = $(window);
      var loginPage = $('.login.page');
      var chatPage = $('.chat.page');

      var username;

      var socket = io("http://localhost:3000");

      function setName(){
        username = $('.usernameInput').val();
        if(username){
          loginPage.fadeOut();
          chatPage.show();
          loginPage.off('click');

          socket.emit('add user',username);
        }
      } //처음 이름 설정시

      function getColor(username){
        var hash = 7;
        for (var i = 0; i < username.length; i++) {
           hash = username.charCodeAt(i) + (hash << 5) - hash;
        }
        var index = Math.abs(hash % COLORS.length);
        return COLORS[index];
      }// 이름에 색칠 정해주기

      function userListUpdate(userlist){
        $('#userList').text('');
        var str='';
        for(var i=0; i<userlist.length; i++){
          if(i==(userlist.length-1))
            {str+= userlist[i];}
          else
            {str += userlist[i]+', ';}
        }
        $('#userList').text(str);
      }

      $window.keydown(function(event){
        if(event.which == 13){
          if(username){
            /* sendMessage();
            socket.emit('stop typing');
            typing = false; */
          }else{
            setName();
          }
        }
      });//엔터를 누를시

      $('form').submit(function(){
        if($('#m').val()[0]=='/'){
            if($('#m').val()[1]=='c'){
              alert("1");
              socket.emit('change nickname',$('#m').val().substring(3));
            }
            else if($('#m').val()[1]=='w'){
              var newmsg = $('#m').val().substring(3);

              var index = newmsg.indexOf(' ');
              var to = newmsg.substring(0,index);
              var msg = newmsg.substring(index+1,newmsg.length);
              socket.emit('whisper',{
                To:to,
                Msg:msg
              });
            }
        }
        else{
          socket.emit('chat message', $('#m').val());
          $('#m').val('');
        }
        return false;
      });// client에서 server로 msg 전송

      socket.on('new nickname', function(data){
        $('#messages').append($('<li class="noti">').text(data.pastname + '님이 ' +data.newname+'으로 닉네임을 변경하였습니다.' ));
        userListUpdate(data.userlist);
      });

      socket.on('chat message', function(data){
        var span = $('<span class="nickname">').text(data.username).css('color', getColor(data.username)).append(' : ');
        var li = $('<li>').append(span).append(data.message);
        $('#messages').append(li);
      }); //chat 내용을 채팅창에 출력

      socket.on('user joined', function(data){
        $('#messages').append($('<li class="noti">').text(data.username + '님이 입장하셨습니다'));
        userListUpdate(data.userlist);
      });

      socket.on('new people',function(data){
        $('#messages').append($('<li class="noti">').text(data.username + '님이 입장하셨습니다'));
        userListUpdate(data.userlist);
      });

      socket.on('user logout',function(data){
        $('#messages').append($('<li class="noti">').text(data.username + '님이 퇴장하셨습니다'));
        userListUpdate(data.userlist);
      });

    </script>
  </body>
  
<!--  body>
    <div id="chat_box"></div>
    <input type="text" id="msg">
    <button id="msg_process">전송</button>
 
    <script src="http://localhost:3000/socket.io/socket.io.js"></script>
    <script src="https://code.jquery.com/jquery-1.11.1.js"></script>
    <script>
            $(document).ready(function(){
                var socket = io("http://localhost:82");
                
                //msg에서 키를 누를떄
                $("#msg").keydown(function(key){
                    //해당하는 키가 엔터키(13) 일떄
                    if(key.keyCode == 13){
                        //msg_process를 클릭해준다.
                        msg_process.click();
                    }
                });
                
                //msg_process를 클릭할 때
                $("#msg_process").click(function(){
                    //소켓에 send_msg라는 이벤트로 input에 #msg의 벨류를 담고 보내준다.
                     socket.emit("send_msg", $("#msg").val());
                    //#msg에 벨류값을 비워준다.
                    $("#msg").val("");
                });
            });
        </script>
</body-->
</html>