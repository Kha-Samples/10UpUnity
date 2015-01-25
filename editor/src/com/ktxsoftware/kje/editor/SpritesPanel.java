package com.ktxsoftware.kje.editor;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JPanel;

public class SpritesPanel extends JPanel implements MouseListener, MouseMotionListener {
	private static final long serialVersionUID = 1L;
	private static SpritesPanel instance;
	private List<Sprite> sprites = new ArrayList<Sprite>();
	private Point mouse = new Point(100, 0);
	private Sprite last = null;
	public Sprite clicked = null;
	public boolean active = false;
	
	static {
		instance = new SpritesPanel();
	}
	
	public static SpritesPanel getInstance() {
		return instance;
	}

	private SpritesPanel() {
		int i = 0;
		sprites.add(new Sprite("../Assets/Graphics/mechanicmini.png", i++, 20, 28));
		sprites.add(new Sprite("../Assets/Graphics/rowdymini.png", i++, 22, 24));
		sprites.add(new Sprite("../Assets/Graphics/toiletwall.png", i++, 48 / 3, 48));
		sprites.add(new Sprite("../Assets/Graphics/elevator.png", i++, 156 / 2, 64));
		sprites.add(new Sprite("../Assets/Graphics/elevatorbuttons.png", i++, 23, 45 / 3));
		sprites.add(new Sprite("../Assets/Graphics/door.png", i++, 128 / 8, 64));
		sprites.add(new Sprite("../Assets/Graphics/toilet.png", i++, 44 / 2, 42));
		sprites.add(new Sprite("../Assets/Graphics/sink.png", i++, 64 / 2, 48));
		sprites.add(new Sprite("../Assets/Graphics/extinguisher.png", i++, 96 / 2, 64));
		sprites.add(new Sprite("../Assets/Graphics/floorlevel.png", i++, 128 / 4, 96 / 3));
		addMouseMotionListener(this);
		addMouseListener(this);
	}
	
	public Sprite getSprite(int index) {
		return sprites.get(index);
	}
	
	public int getSpriteCount() {
		return sprites.size();
	}

	public void paint(Graphics g) {
		Rectangle rect = getVisibleRect();
		g.setColor(Color.WHITE);
		g.fillRect(rect.x, rect.y, rect.width, rect.height);
		int x = 0;
		int y = 0;
		int ymax = 0;
		for (Sprite sprite : sprites) {
			boolean hovering = mouse.x >= x && mouse.x <= x + sprite.width && mouse.y >= y && mouse.y <= y + sprite.height;
			if (hovering) last = sprite;
			sprite.paint(g, x, y, hovering, false);
			x += sprite.width;
			if (sprite.height > ymax) ymax = sprite.height;
			if (x > 300) {
				x = 0;
				y += ymax;
				ymax = 0;
			}
		}
	}
	
	public void mouseMoved(MouseEvent e) {
		mouse = e.getPoint();
		repaint();
	}

	public void mousePressed(MouseEvent e) {
		for (Sprite sprite : sprites) sprite.selected = false;
		last.selected = true;
		clicked = last;
		active = true;
		TilesetPanel.getInstance().active = false;
		repaint();
	}

	@Override
	public void mouseDragged(MouseEvent arg0) {
		
	}

	@Override
	public void mouseClicked(MouseEvent arg0) {
			
	}

	@Override
	public void mouseEntered(MouseEvent arg0) {
		
	}

	@Override
	public void mouseExited(MouseEvent arg0) {
		
	}

	@Override
	public void mouseReleased(MouseEvent arg0) {
		
	}
}
