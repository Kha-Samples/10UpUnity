package com.ktxsoftware.kje.editor;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.util.ArrayList;

import javax.swing.JPanel;

public class TilesetPanel extends JPanel implements MouseListener, MouseMotionListener {
	private static final long serialVersionUID = 1L;
	
	public static final int PANEL_WIDTH = 512;
	public static final int PANEL_HEIGHT = 736;
	
	private static TilesetPanel instance;
	
	private Tileset tileset;
	private Point mouse = new Point(0, 0);
	private int last;
	private int start;
	private ArrayList<Integer> selectedElements = new ArrayList<Integer>();

	public boolean active = true;
	
	static {
		instance = new TilesetPanel();
	}

	public static TilesetPanel getInstance() {
		return instance;
	}

	private TilesetPanel() {
		tileset = new Tileset(
				"../Assets/Graphics/tileset_s.png",
				Level.TILE_WIDTH, Level.TILE_HEIGHT);
		setPreferredSize(new Dimension(PANEL_WIDTH, PANEL_HEIGHT));
		addMouseMotionListener(this);
		addMouseListener(this);
	}
	
	private int tileX(int tile) {
		return Level.TILE_WIDTH * tile % PANEL_WIDTH;
	}
	
	private int tileY(int tile) {
		return (Level.TILE_HEIGHT * tile / PANEL_WIDTH) * Level.TILE_HEIGHT;
	}
	
	private int tile(int x, int y) {
		return (y / Level.TILE_HEIGHT) * (PANEL_WIDTH / Level.TILE_WIDTH) + (x / Level.TILE_WIDTH);
	}

	public void paint(Graphics g) {
		Rectangle rect = getVisibleRect();
		g.setColor(Color.WHITE);
		g.fillRect(rect.x, rect.y, rect.width, rect.height);
		for (int tile = 0; tile < tileset.getLength(); ++tile) {
			int x = tileX(tile);
			int y = tileY(tile);
			tileset.paint(g, tile, x, y);
			if (mouse.x > x && mouse.x < x + Level.TILE_WIDTH && mouse.y > y && mouse.y < y + Level.TILE_HEIGHT) {
				markTile(g, new Color(1, 0, 0, 0.5f), x, y);
				last = tile;
			}
			if (isSelected(tile)) markTile(g, new Color(0, 0.5f, 0, 0.5f), x, y);
		}
	}
	
	private void markTile(Graphics g, Color c, int x, int y) {
		g.setColor(c);
		g.fillRect(x, y, Level.TILE_WIDTH, Level.TILE_HEIGHT);
	}
	
	private boolean isSelected(int tile) {
		for (int selectedElement : selectedElements) if (tile == selectedElement) return true;
		return false;
	}

	public ArrayList<Integer> getSelectedElements() {
		return selectedElements;
	}
	
	public Tileset getTileset() {
		return tileset;
	}

	public void mouseMoved(MouseEvent e) {
		mouse = e.getPoint();
		repaint();
	}

	public void mousePressed(MouseEvent e) {
		selectedElements.clear();
		selectedElements.add(last);
		start = last;
		active = true;
		SpritesPanel.getInstance().active = false;
		repaint();
	}

	public void mouseDragged(MouseEvent e) {
		int xstart = tileX(start);
		int ystart = tileY(start);
		int xend = tileX(last);
		int yend = tileY(last);
		if (xend < xstart) {
			int temp = xstart;
			xstart = xend;
			xend = temp;
		}
		if (yend < ystart) {
			int temp = ystart;
			ystart = yend;
			yend = temp;
		}
		selectedElements.clear();
		for (int x = xstart; x <= xend; ++x) {
			for (int y = ystart; y <= yend; ++y) {
				selectedElements.add(tile(x, y));
			}
		}
		mouse = e.getPoint();
		repaint();
	}
	
	public void mouseClicked(MouseEvent e) { }
	
	public void mouseReleased(MouseEvent e) { }
	
	public void mouseEntered(MouseEvent e) { }
	
	public void mouseExited(MouseEvent e) { }
}