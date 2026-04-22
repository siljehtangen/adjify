import 'dotenv/config';
import express, { Request } from 'express';
import cors from 'cors';
import { createServer } from 'http';
import { Server } from 'socket.io';
import roomsRouter from './routes/rooms.js';
import storiesRouter from './routes/stories.js';
import chainRouter from './routes/chain.js';
import battleRouter from './routes/battle.js';
import { setupSockets } from './services/socketService.js';

declare global {
  namespace Express {
    interface Request {
      io: Server;
    }
  }
}

const app = express();
const httpServer = createServer(app);

const allowedOrigins = (process.env.FRONTEND_URL || 'http://localhost:8080').split(',').map(o => o.trim());

const io = new Server(httpServer, {
  cors: {
    origin: allowedOrigins,
    credentials: true,
  },
});

app.use(cors({ origin: allowedOrigins, credentials: true }));
app.use(express.json());

// Attach io instance to requests so routes can emit events
app.use((req: Request, _res, next) => {
  req.io = io;
  next();
});

app.get('/health', (_req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

app.use('/api/rooms', roomsRouter);
app.use('/api/rooms/:code/stories', storiesRouter);
app.use('/api/rooms/:code/chain', chainRouter);
app.use('/api/rooms/:code/battle', battleRouter);

setupSockets(io);

const PORT = process.env.PORT || 3000;
httpServer.listen(PORT, () => {
  console.log(`Adjify backend running on port ${PORT}`);
});

httpServer.on('error', (err) => {
  console.error('[server] Failed to start:', err.message);
  process.exit(1);
});

export { io };
