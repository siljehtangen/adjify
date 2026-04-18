import { Server, Socket } from 'socket.io';
import { createRemoteJWKSet, jwtVerify } from 'jose';

const JWKS_URL = `${process.env.SUPABASE_URL}/auth/v1/.well-known/jwks.json`;
const JWKS = createRemoteJWKSet(new URL(JWKS_URL));

interface AuthSocket extends Socket {
  userId?: string;
}

export function setupSockets(io: Server) {
  // Authenticate socket connections via JWT
  io.use(async (socket: AuthSocket, next) => {
    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error('Authentication required'));

    try {
      const { payload } = await jwtVerify(token, JWKS, {
        issuer: `${process.env.SUPABASE_URL}/auth/v1`,
        audience: 'authenticated',
      });
      socket.userId = payload.sub as string;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket: AuthSocket) => {
    // Join a room channel
    socket.on('join_room', (roomCode: string) => {
      socket.join(`room:${roomCode}`);
      socket.to(`room:${roomCode}`).emit('room:player_joined', { userId: socket.userId });
    });

    socket.on('leave_room', (roomCode: string) => {
      socket.leave(`room:${roomCode}`);
      socket.to(`room:${roomCode}`).emit('room:player_left', { userId: socket.userId });
    });

    socket.on('disconnect', () => {
      // Rooms auto-cleaned by socket.io on disconnect
    });
  });
}

/** Emit to everyone in a room (called from routes after DB writes) */
export function emitToRoom(io: Server, roomCode: string, event: string, data: unknown) {
  io.to(`room:${roomCode}`).emit(event, data);
}
