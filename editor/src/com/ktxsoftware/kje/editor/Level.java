package com.ktxsoftware.kje.editor;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Rectangle;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JPanel;

public class Level extends JPanel implements MouseListener, MouseMotionListener, KeyListener {
	private static final long serialVersionUID = 1L;
	
	public static final int TILE_WIDTH = 16;
	public static final int TILE_HEIGHT = 16;
	
	private static Level instance;
	
	private int levelWidth = 256;
	private int levelHeight = 224 / 16;
	private int[][] map;
	
	private boolean shift, ctrl;
	
	class PlacedSprite {
		public int x;
		public int y;
		public Sprite sprite;
		public int id;
		
		public PlacedSprite(int x, int y, Sprite sprite, int id) {
			this.x = x;
			this.y = y;
			this.sprite = sprite;
			this.id = id;
		}
	}
	
	private List<PlacedSprite> sprites = new ArrayList<PlacedSprite>();

	static {
		instance = new Level();
	}

	public static Level getInstance() {
		return instance;
	}

	public int getLevelWidth() {
		return levelWidth;
	}

	public int getLevelHeight() {
		return levelHeight;
	}

	private Level() {
		map = new int[levelWidth][levelHeight];
		addMouseListener(this);
		addMouseMotionListener(this);
		setPreferredSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
	}

	public void paint(Graphics g) {
		Rectangle rect = getVisibleRect();
		g.setColor(Color.WHITE);
		g.fillRect(rect.x, rect.y, rect.width, rect.height);
		for (int x = rect.x / TILE_WIDTH; x < Math.min((rect.x + rect.width) / TILE_WIDTH + 1, levelWidth); ++x)
			for (int y = rect.y / TILE_HEIGHT; y < Math.min((rect.y + rect.height) / TILE_HEIGHT + 1, levelHeight); ++y)
				TilesetPanel.getInstance().getTileset().paint(g, map[x][y], x * TILE_WIDTH,y * TILE_HEIGHT);
		g.setColor(Color.BLACK);
		for (int x = rect.x / TILE_WIDTH * TILE_WIDTH; x < rect.x + rect.width; x += TILE_WIDTH) g.drawLine(x, rect.y, x, rect.y + rect.height);
		for (int y = rect.y / TILE_HEIGHT * TILE_HEIGHT; y < rect.y + rect.height; y += TILE_HEIGHT) g.drawLine(rect.x, y, rect.x + rect.width, y);
		
		for (PlacedSprite sprite : sprites) {
			g.setColor(Color.BLUE);
			g.fillRect(sprite.x, sprite.y, sprite.sprite.width, sprite.sprite.height);
			sprite.sprite.paint(g, sprite.x, sprite.y, false, true);
			g.drawString("" + sprite.id, sprite.x + 5, sprite.y + 15);
		}
	}

	public void save(DataOutputStream stream) {
		try {
			stream.writeInt(levelWidth);
			stream.writeInt(levelHeight);
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) stream.writeInt(map[x][y]);
			stream.writeInt(sprites.size());
			for (PlacedSprite sprite : sprites) {
				stream.writeInt(sprite.sprite.index);
				stream.writeInt(sprite.x);
				stream.writeInt(sprite.y);
			}
		}
		catch (IOException ex) {
			ex.printStackTrace();
		}
		finally {
			try {
				stream.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public void load(DataInputStream stream) {
		try {
			sprites.clear();
			levelWidth = stream.readInt();
			levelHeight = stream.readInt();
			map = new int[levelWidth][levelHeight];
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) map[x][y] = stream.readInt();
			int count = stream.readInt();
			for (int i = 0; i < count; ++i) {
				int index = stream.readInt();
				int x = stream.readInt();
				int y = stream.readInt();
				int id = 0;
				for (PlacedSprite sprite : sprites) {
					if (sprite.sprite.index == index) ++id;
				}
				sprites.add(new PlacedSprite(x, y, SpritesPanel.getInstance().getSprite(index), id));
			}
		}
		catch (IOException ex) {
			ex.printStackTrace();
		}
		finally {
			try {
				stream.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
		setPreferredSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
		setSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
	}

	public void mouseReleased(MouseEvent e) {
		if (TilesetPanel.getInstance().active) {
			int x = e.getX() / TILE_WIDTH;
			int y = e.getY() / TILE_HEIGHT;
			int smallestX = Integer.MAX_VALUE;
			int smallestY = Integer.MAX_VALUE;
			int widthCount = TilesetPanel.PANEL_WIDTH / Level.TILE_WIDTH;
			for (int index : TilesetPanel.getInstance().getSelectedElements()) {
				if (smallestX > index % widthCount) smallestX = index % widthCount;
				if (smallestY > index / widthCount) smallestY = index / widthCount;
			}
			for (int index : TilesetPanel.getInstance().getSelectedElements()) map[x + index % widthCount - smallestX][y + index / widthCount - smallestY] = index;
		}
		else {
			int x = e.getX();
			int y = e.getY();
			
			if (ctrl) {
				for (PlacedSprite sprite : sprites) {
					if (x > sprite.x && y > sprite.y && x < sprite.x + sprite.sprite.width && y < sprite.y + sprite.sprite.height) {
						sprites.remove(sprite);
						break;
					}
				}
			}
			else {
				if (shift) {
					x /= TILE_WIDTH;
					y /= TILE_HEIGHT;
					x *= TILE_WIDTH;
					y *= TILE_HEIGHT;
				}
				int id = 0;
				for (PlacedSprite sprite : sprites) {
					if (sprite.sprite.index == SpritesPanel.getInstance().clicked.index) ++id;
				}
				sprites.add(new PlacedSprite(x, y, SpritesPanel.getInstance().clicked, id));
			}
		}
		repaint();
	}
	
	public void mouseClicked(MouseEvent e) { }
	
	public void mousePressed(MouseEvent e) { }
	
	public void mouseEntered(MouseEvent e) { }
	
	public void mouseExited(MouseEvent e) { }
	
	public void mouseDragged(MouseEvent e) {
		InfoBar.getInstance().update(e.getX(), e.getY());
		map[e.getX() / TILE_WIDTH][e.getY() / TILE_HEIGHT] = TilesetPanel.getInstance().getSelectedElements().get(0);
		repaint();
	}
	
	public void mouseMoved(MouseEvent e) {
		InfoBar.getInstance().update(e.getX(), e.getY());
	}
	
	public void resizeLevel(int w, int h) {
		int[][] newmap = new int[w][h];
		for (int y = 0; y < h; ++y) {
			for (int x = 0; x < w; ++x) {
				if (x < levelWidth && y < levelHeight) newmap[x][y] = map[x][y];
			}
		}
		map = newmap;
		levelWidth = w;
		levelHeight = h;
		setPreferredSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
		repaint();
	}
	
	public void resetMaps() {
		map = new int[levelWidth][levelHeight];
		repaint();
	}

	@Override
	public void keyPressed(KeyEvent e) {
		if (e.getKeyCode() == KeyEvent.VK_SHIFT) shift = true;
		if (e.getKeyCode() == KeyEvent.VK_CONTROL) ctrl = true;
	}

	@Override
	public void keyReleased(KeyEvent e) {
		if (e.getKeyCode() == KeyEvent.VK_SHIFT) shift = false;
		if (e.getKeyCode() == KeyEvent.VK_CONTROL) ctrl = false;
	}

	@Override
	public void keyTyped(KeyEvent e) {
		
	}
}
