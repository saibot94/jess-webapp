package servlets;

import java.awt.Color;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jess.Fact;
import jess.JessException;
import jess.Rete;
import jess.Value;

/**
 * Servlet implementation class HelloJess
 */
@WebServlet("/HelloJess")
public class HelloJess extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public HelloJess() { 
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html");
		PrintWriter out = response.getWriter();
		Rete engine = new Rete();
		engine.addOutputRouter("page", out);
		
		try {
			
			Color pink = new Color(255,200,200);
			engine.store("PINK", pink);
			Value v = engine.executeCommand("(assert (color (fetch PINK)))");
			
			Fact f = v.factValue(engine.getGlobalContext());
			Color pink2 = (Color)engine.fetch("PINK").externalAddressValue(engine.getGlobalContext());
			print(pink2.toString(), engine);
			
		} catch (JessException e) {
			e.printStackTrace();
		}
		
		try{
			print("<html>", engine);
			print("<head>", engine);
			print("<title>Hello World from jess!</title>", engine);
			print("</head>", engine);
			print("<body>", engine);
			print("<h1>Hello World from Jess!</h1>", engine);
			print("</body>", engine);
			print("</html>", engine);
		}
		catch(JessException ex){
			ex.printStackTrace();
		}
	}
	
	private void print(String input, Rete engine) 
			throws JessException{
		engine.executeCommand("(printout page \"" + input +
				"\" crlf)");
	}
	

}
