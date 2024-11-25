package com.example.workus.websocket;

import com.example.workus.chat.service.ChatService;
import com.example.workus.chat.vo.Chat;
import com.example.workus.chat.vo.Chatroom;
import com.example.workus.user.mapper.UserMapper;
import com.example.workus.user.vo.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.security.Principal;
import java.util.*;

@Slf4j
@Transactional
@Service
public class ChatSocketHandler extends TextWebSocketHandler {
    @Autowired private UserMapper userMapper;
    @Autowired private ChatService chatService;

    private ObjectMapper objectMapper = new ObjectMapper();

    // 채팅이 진행중인 채팅방 Map<채팅방 번호, Map<유저 아이디, 세션>> 형태로 저장
    private Map<Long, Map<String, WebSocketSession>> chatrooms = Collections.synchronizedMap(new HashMap<>());

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        ChatMessage chatMessage = objectMapper.readValue(message.getPayload(), ChatMessage.class);
        String cmd = chatMessage.getCmd();

        if ("chat-open".equals(cmd)) {
            openchatroom(session, chatMessage);
        } else if ("chat-message".equals(cmd)) {
            chatting(session, chatMessage);
        } else if ("chat-close".equals(cmd)) {
            closechatroom(session, chatMessage);
        }
    }

    private void openchatroom(WebSocketSession session, ChatMessage chatMessage) throws IOException {
        // 채팅방에 들어온 유저 id
        String userId = chatMessage.getUserId();
        // 채팅방 no
        Long chatroomNo = chatMessage.getChatroomNo();
        // <식별자, webSocketSession> 형태로 chatrooms에 담을 그릇
        Map<String, WebSocketSession> chatroom = chatrooms.get(chatroomNo);
        if (chatroom == null) {
            chatroom = new HashMap<>();
            chatroom.put(userId, session);
            chatrooms.put(chatroomNo, chatroom);
        } else {
            chatroom.put(userId, session);
        }

        ChatMessage responseChatMessage = new ChatMessage();
        responseChatMessage.setCmd("chat-open-success");
        responseChatMessage.setChatroomNo(chatroomNo);
        responseChatMessage.setUserId(userId);

        User user = userMapper.getUserById(userId);
        responseChatMessage.setText(user.getName() + "님이 채팅방에 접속하셨습니다.");

        session.sendMessage(new TextMessage(objectMapper.writeValueAsBytes(responseChatMessage)));
    }

    private void closechatroom(WebSocketSession session, ChatMessage chatMessage) throws IOException {
        // 삭제
        Long chatroomNo = chatMessage.getChatroomNo();
        chatrooms.remove(chatroomNo);

        User user = userMapper.getUserById(chatMessage.getUserId());
        ChatMessage responseChatMessage = new ChatMessage();
        responseChatMessage.setCmd("chat-close-success");
        responseChatMessage.setText(user.getName() + "님이 채팅방에서 나갔습니다.");

        session.sendMessage(new TextMessage(objectMapper.writeValueAsBytes(responseChatMessage)));
    }

    private void chatting(WebSocketSession session, ChatMessage chatMessage) throws IOException {
        Long chatroomNo = chatMessage.getChatroomNo();
        Long userNo = chatMessage.getUserNo();
        Map<String, WebSocketSession> chatroom = chatrooms.get(chatroomNo);

        Chat chat = new Chat();
        Chatroom chatroomVo = new Chatroom();
        chatroomVo.setNo(chatMessage.getChatroomNo());
        chat.setChatroom(chatroomVo);
        User user = userMapper.getUserByUserNo(userNo);
        chat.setUser(user);
        chat.setContent(chatMessage.getText());
        chatService.insertChat(chat);
        chatMessage.setChat(chat);
        // jsr301 모듈 등록
        objectMapper.registerModule(new JavaTimeModule());
        // 변환 한 번만 하기 위해서 담기
        byte[] chatMessageBytes = objectMapper.writeValueAsBytes(chatMessage);

        for (WebSocketSession userSession : chatroom.values()) {
            if (userSession != null && userSession.isOpen()) {
                userSession.sendMessage(new TextMessage(chatMessageBytes));
            }
        }
    }

    private void removeWebSocketSession(WebSocketSession session) {
        Principal principal = session.getPrincipal();
        if (principal != null) {
            String loginId = principal.getName();
            Set<Long> chatroomNoSet = chatrooms.keySet();
            Iterator<Long> iterator = chatroomNoSet.iterator();
            while (iterator.hasNext()) {
                Long chatroomNo = iterator.next();
                Map<String, WebSocketSession> chatroom = chatrooms.get(chatroomNo);
                if(chatroom.containsKey(loginId)) {
                    chatroom.remove(loginId);
                    if(chatrooms.get(chatroomNo).isEmpty()) {
                        chatrooms.remove(chatroomNo);
                    }
                }
            }
        }
    }

    // 클라이언트와 웹 소켓 연결이 종료되면 세션을 삭제한다.
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        removeWebSocketSession(session);
    }

    // 메시지를 주고 받던 중 에러가 발생하면 세션을 삭제한다.
    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        removeWebSocketSession(session);
    }
}
