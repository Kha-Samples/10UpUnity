package com.ktxsoftware.kje.editor;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class ResizeDialog extends JDialog {
	private static final long serialVersionUID = 1L;

	public ResizeDialog(JFrame owner) {
		super(owner, true);
		
		JPanel main = new JPanel();
		main.setLayout(new BoxLayout(main, BoxLayout.Y_AXIS));
		
		JPanel input = new JPanel();
		input.setLayout(new BoxLayout(input, BoxLayout.X_AXIS));
		input.add(new JLabel("Width:"));
		final JTextField width = new JTextField();
		input.add(width);
		input.add(new JLabel("Height:"));
		final JTextField height = new JTextField();
		input.add(height);
		
		JPanel buttons = new JPanel();
		buttons.setLayout(new BoxLayout(buttons, BoxLayout.X_AXIS));
		JButton okbutton = new JButton("OK");
		okbutton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				try {
					Level.getInstance().resizeLevel(Integer.parseInt(width.getText()), Integer.parseInt(height.getText()));
				}
				catch (Exception ex) {
					ex.printStackTrace();
				}
				ResizeDialog.this.dispose();
			}
		});
		buttons.add(okbutton);
		JButton cancelbutton = new JButton("Cancel");
		cancelbutton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				ResizeDialog.this.dispose();
			}
		});
		buttons.add(cancelbutton);
		
		main.add(input);
		main.add(buttons);
		
		add(main);
		
		pack();
		setVisible(true);
	}
}
