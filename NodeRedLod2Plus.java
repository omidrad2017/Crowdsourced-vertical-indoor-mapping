package org;

import java.awt.Point;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import org.citygml4j.builder.CityGMLBuilder;
import org.citygml4j.CityGMLContext;
import org.citygml4j.builder.jaxb.JAXBBuilder;
import org.citygml4j.factory.DimensionMismatchException;
import org.citygml4j.factory.GMLGeometryFactory;
import org.citygml4j.model.citygml.CityGMLClass;
import org.citygml4j.model.citygml.building.AbstractBoundarySurface;
import org.citygml4j.model.citygml.building.BoundarySurfaceProperty;
import org.citygml4j.model.citygml.building.Building;
import org.citygml4j.model.citygml.building.Door;
import org.citygml4j.model.citygml.building.FloorSurface;
import org.citygml4j.model.citygml.building.GroundSurface;
import org.citygml4j.model.citygml.building.InteriorWallSurface;
import org.citygml4j.model.citygml.building.OpeningProperty;
import org.citygml4j.model.citygml.building.RoofSurface;
import org.citygml4j.model.citygml.building.WallSurface;
import org.citygml4j.model.citygml.building.Window;
import org.citygml4j.model.citygml.core.CityModel;
import org.citygml4j.model.citygml.core.CityObjectMember;
import org.citygml4j.model.gml.geometry.aggregates.MultiSurface;
import org.citygml4j.model.gml.geometry.aggregates.MultiSurfaceProperty;
import org.citygml4j.model.gml.geometry.complexes.CompositeSurface;
import org.citygml4j.model.gml.geometry.primitives.DirectPositionList;
import org.citygml4j.model.gml.geometry.primitives.Exterior;
import org.citygml4j.model.gml.geometry.primitives.LinearRing;
import org.citygml4j.model.gml.geometry.primitives.Polygon;
import org.citygml4j.model.gml.geometry.primitives.Solid;
import org.citygml4j.model.gml.geometry.primitives.SolidProperty;
import org.citygml4j.model.gml.geometry.primitives.SurfaceProperty;
import org.citygml4j.model.module.citygml.CityGMLVersion;
import org.citygml4j.util.gmlid.DefaultGMLIdManager;
import org.citygml4j.util.gmlid.GMLIdManager;
import org.citygml4j.xml.io.CityGMLOutputFactory;
import org.citygml4j.xml.io.writer.CityGMLWriter;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import java.sql.*;
// to read csv file in java:
import java.io.BufferedReader; 
import java.io.IOException; 
import java.nio.charset.StandardCharsets; 
import java.nio.file.Files; 
import java.nio.file.Path; 
import java.nio.file.Paths; 
import java.util.ArrayList; 
import java.util.List;


public class NodeRedLod2Plus {

	public static void main(String[] args) throws Exception {
		new NodeRedLod2Plus().doMain();
	}

	public void doMain() throws Exception {
		SimpleDateFormat df = new SimpleDateFormat("[HH:mm:ss] "); 
		System.out.println(df.format(new Date()) + "setting up citygml4j context and JAXB builder");
		CityGMLContext ctx = new CityGMLContext();
		CityGMLBuilder builder = ctx.createCityGMLBuilder();
		System.out.println(df.format(new Date()) + "creating LOD2+ building as citygml4j in-memory object tree");
		GMLGeometryFactory geom = new GMLGeometryFactory();
		JAXBBuilder builder2 = ctx.createJAXBBuilder();	
	        System.out.println(df.format(new Date()) + "creating LOD4 building as citygml4j in-memory object tree");
		GMLGeometryFactory geom2 = new GMLGeometryFactory();
		GMLIdManager gmlIdManager = DefaultGMLIdManager.getInstance();
		Building building = new Building();

		List<Foot> foots = readFootsFromCSV("E:\\Thesis Indoor Mapping\\node-red-0.16.0\\node-red-0.16.0\\finalFootprint.csv"); 
		List<List<Double>> RXYZs = new ArrayList<List<Double>>();
		// Convert from GPS to WGS84 coordinate system
		//double EarthRadius = 6337000;
		for (Foot b: foots) {
			List<Double> RXYZ = new ArrayList<Double>();
			double Re = 6378137;
			double Rp = 6356752.31424518;
                        double ref =  b.getRef();
			double latrad = b.getLat()/180.0*Math.PI;
			double lonrad = b.getLon()/180.0*Math.PI;
	
			double coslat = Math.cos(latrad);
			double sinlat = Math.sin(latrad);
			double coslon = Math.cos(lonrad);
			double sinlon = Math.sin(lonrad);

			double term1 = (Re*Re*coslat)/Math.sqrt(Re*Re*coslat*coslat + Rp*Rp*sinlat*sinlat);

			double term2 = 520*coslat + term1;

			double x=coslon*term2;
			double y=sinlon*term2;
			double z = 520*sinlat + (Rp*Rp*sinlat)/
			Math.sqrt(Re*Re*coslat*coslat + Rp*Rp*sinlat*sinlat);
			
			System.out.println((int)ref+" "+x+" "+y+" "+z);
			
			RXYZ.add(ref);
			RXYZ.add(x);
			RXYZ.add(y);
			RXYZ.add(z);
			RXYZs.add(RXYZ);
		}
		
		// read ref values of way

		DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder mybuilder = dbFactory.newDocumentBuilder();
		Document doc = mybuilder.parse("E://Thesis Indoor Mapping//node-red-0.16.0//node-red-0.16.0//TUM_footprint.osm");
		XPathFactory xPathfactory = XPathFactory.newInstance();
		XPath xpath = xPathfactory.newXPath();
		XPathExpression expr = xpath.compile("//nd/@ref");
		NodeList nl = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
		doc.getDocumentElement().normalize();

		//System.out.println("Reference values of the way:");
		
		// Ground floor
                int count = 0;
		double[] myArrayForGround = new double[RXYZs.size()*3];
		for (int i = 0; i < nl.getLength(); i++){ 
		   //System.out.println(nl.item(i).getTextContent());
		   // end of reading ref values of way
		   for (int j = 0; j < RXYZs.size(); j++){
			   if (Double.parseDouble(nl.item(i).getTextContent())==RXYZs.get(j).get(0)){
				  //System.out.println(RXYZs.get(j).get(1)); 	   
				   myArrayForGround[count] = RXYZs.get(j).get(1);
				   myArrayForGround[count+1] = RXYZs.get(j).get(2);
				   myArrayForGround[count+2] = RXYZs.get(j).get(3);
				   count = count+3;
			   }
		   }
			   
		}

		Polygon ground = geom.createLinearPolygon(myArrayForGround,3);
		
	
	       // roof
	       // compute normal to the ground floor polygon
	       double x1 = RXYZs.get(1).get(1);
	       double y1 = RXYZs.get(1).get(2);
	       double z1 = RXYZs.get(1).get(3);
	       
	       double x2 = RXYZs.get(3).get(1);
	       double y2 = RXYZs.get(3).get(2);
	       double z2 = RXYZs.get(3).get(3);
	       
	       double x3 = RXYZs.get(5).get(1);
	       double y3 = RXYZs.get(5).get(2);
	       double z3 = RXYZs.get(5).get(3);
		   double u1, u2, u3, v1, v2, v3;
	        u1 = x1 - x2;
	        u2 = y1 - y2;
	        u3 = z1 - z2;
	        v1 = x3 - x2;
	        v2 = y3 - y2;
	        v3 = z3 - z2;
	 
	        double uvi, uvj, uvk; // normal to ground floor, so we can shift the ground floor with building height  to form the roof in direction of this normaal
	        uvi = u2 * v3 - v2 * u3;
	        uvj = v1 * u3 - u1 * v3;
	        uvk = u1 * v2 - v1 * u2;
	        
	        //normal unit vector
	        double un1 = uvi/Math.sqrt(Math.pow(uvi, 2)+Math.pow(uvj, 2)+Math.pow(uvk, 2));
	        double un2 = uvj/Math.sqrt(Math.pow(uvi, 2)+Math.pow(uvj, 2)+Math.pow(uvk, 2));
	        double un3 = uvk/Math.sqrt(Math.pow(uvi, 2)+Math.pow(uvj, 2)+Math.pow(uvk, 2));

	        System.out.println("The cross product of the 2 vectors \n u = " + u1
	                + "i + " + u2 + "j + " + u3 + "k and \n v = " + u1 + "i + "
	                + u2 + "j + " + u3 + "k \n ");
	        System.out.println("u X v : " + uvi + "i +" + uvj + "j+ " + uvk + "k ");
	        System.out.println("unit vector of u X v : " + un1 + "i +" + un2 + "j+ " + un3 + "k ");
		
		// real building height
	        double h = 24;
	        // computed building height vector for shifting ground
	        double new_h_v1 = h * un1;
	        double new_h_v2 = h * un2;
	        double new_h_v3 = h * un3;
		int count2 = 0;
		double[] myArrayForRoof = new double[RXYZs.size()*3];
		for (int i = 0; i < nl.getLength(); i++){ 
		   //System.out.println(nl.item(i).getTextContent());
		   // end of reading ref values of way
		   for (int j = 0; j < RXYZs.size(); j++){
			   if (Double.parseDouble(nl.item(i).getTextContent())==RXYZs.get(j).get(0)){
				  //System.out.println(RXYZs.get(j).get(1)); 
				   
				   myArrayForRoof[count2] = RXYZs.get(j).get(1)+new_h_v1;
				   myArrayForRoof[count2+1] = RXYZs.get(j).get(2)+new_h_v2;
				   myArrayForRoof[count2+2] = RXYZs.get(j).get(3)+new_h_v3;
				   count2 = count2+3;
			   }
		   }
			   
		}
	

		Polygon roof = geom.createLinearPolygon(myArrayForRoof,3);
				
		// Floors
		// assume we have received number of floors and each floor height
		// now we want to add these floors to our model
		
		List<Polygon> floors = new ArrayList<Polygon>();
		int num_of_floors = 3; // except ground floor and roof
		double [] each_floor_height = {6, 12, 18};
		for (int t =0; t<num_of_floors; t++){
			 double floor_h = each_floor_height[t];
			    // computed floor height vector for shifting ground
			        double new_fh_v1 = floor_h * un1;
			        double new_fh_v2 = floor_h * un2;
			        double new_fh_v3 = floor_h * un3;
				int counter2 = 0;
				double[] myArrayForFloor = new double[RXYZs.size()*3];
				for (int i = 0; i < nl.getLength(); i++){ 
				   for (int j = 0; j < RXYZs.size(); j++){
					   if (Double.parseDouble(nl.item(i).getTextContent())==RXYZs.get(j).get(0)){
						  //System.out.println(RXYZs.get(j).get(1)); 
						   
						   myArrayForFloor[counter2] = RXYZs.get(j).get(1)+new_fh_v1;
						   myArrayForFloor[counter2+1] = RXYZs.get(j).get(2)+new_fh_v2;
						   myArrayForFloor[counter2+2] = RXYZs.get(j).get(3)+new_fh_v3;
						   counter2 = counter2+3;
					   }
				   }
					   
				}
			

				Polygon floor = geom.createLinearPolygon(myArrayForFloor,3);
			    
				floors.add(floor);
				for (int i=0; i<floors.size(); i++){
			       	 floors.get(i).setId(gmlIdManager.generateUUID());
			        }
			
		}
		
	        // walls
	
	        List<Polygon> walls = new ArrayList<Polygon>();
	        int k=0;
                for (int i=0; i<3*RXYZs.size(); i++){
        	
                 walls.add(geom.createLinearPolygon(new double[] {
            			 
       			 myArrayForGround[k],myArrayForGround[k+1], myArrayForGround[k+2], 
       			 myArrayForGround[k+3],myArrayForGround[k+4], myArrayForGround[k+5],
       			 myArrayForRoof[k+3],myArrayForRoof[k+4], myArrayForRoof[k+5],
       			 myArrayForRoof[k],myArrayForRoof[k+1], myArrayForRoof[k+2],
       			 myArrayForGround[k],myArrayForGround[k+1], myArrayForGround[k+2]},3));
       	 
                 if (k+3 <3*RXYZs.size()-3)
       	             k+=3;
                }
        
                System.out.println(walls.size());
        
                for (int i=0; i<walls.size(); i++){
       	          walls.get(i).setId(gmlIdManager.generateUUID());
                }
        
		ground.setId(gmlIdManager.generateUUID());
		roof.setId(gmlIdManager.generateUUID());

		// lod2 solid
		
		List<SurfaceProperty> surfaceMember = new ArrayList<SurfaceProperty>();
		surfaceMember.add(new SurfaceProperty('#' + ground.getId()));
		surfaceMember.add(new SurfaceProperty('#' + roof.getId()));
		for (int i=0; i<walls.size(); i++){
			surfaceMember.add(new SurfaceProperty('#' + walls.get(i).getId()));
	        }
		
		for (int i=0; i<floors.size(); i++){
			surfaceMember.add(new SurfaceProperty('#' + floors.get(i).getId()));
	        }
		
		// Assume an OI transition detected at wall number 1
		int I_O = 1;
		BoundarySurfaceProperty wall_1_BSurf = createBoundarySurface(CityGMLClass.BUILDING_WALL_SURFACE, walls.get(I_O));		
		createDoor(wall_1_BSurf);
		
		CompositeSurface compositeSurface = new CompositeSurface();
		compositeSurface.setSurfaceMember(surfaceMember);		
		Solid solid = new Solid();
		solid.setExterior(new SurfaceProperty(compositeSurface));

		building.setLod4Solid(new SolidProperty(solid));
		

		// thematic boundary surfaces
		List<BoundarySurfaceProperty> boundedBy = new ArrayList<BoundarySurfaceProperty>();
		boundedBy.add(createBoundarySurface(CityGMLClass.BUILDING_GROUND_SURFACE, ground));
		boundedBy.add(createBoundarySurface(CityGMLClass.BUILDING_ROOF_SURFACE, roof));
		boundedBy.add(wall_1_BSurf);

		for (int i=0; i<walls.size(); i++){
			boundedBy.add(createBoundarySurface(CityGMLClass.BUILDING_WALL_SURFACE, walls.get(i)));
		    }
		
		for (int i=0; i<floors.size(); i++){
			boundedBy.add(createBoundarySurface(CityGMLClass.BUILDING_FLOOR_SURFACE, floors.get(i)));
		    }
		
		//BoundarySurfaceProperty wall3_2_BSurf = createBoundarySurface(CityGMLClass.BUILDING_WALL_SURFACE, wall_3);		
		//createWindow(wall3_2_BSurf);			
		//boundedBy.add(wall3_2_BSurf);
		
		building.setBoundedBySurface(boundedBy);

		CityModel cityModel = new CityModel();
		cityModel.setBoundedBy(building.calcBoundedBy(false));
		cityModel.addCityObjectMember(new CityObjectMember(building));

		System.out.println(df.format(new Date()) + "writing citygml4j object tree");
		CityGMLOutputFactory out = builder.createCityGMLOutputFactory(CityGMLVersion.DEFAULT);
		CityGMLWriter writer = out.createCityGMLWriter(new File("MainCampGround.gml"));

		writer.setPrefixes(CityGMLVersion.DEFAULT);
		writer.setSchemaLocations(CityGMLVersion.DEFAULT);
		writer.setIndentString("  ");
		writer.write(cityModel);
		writer.close();	
		
		System.out.println(df.format(new Date()) + "CityGML file LOD4_Building_v200.gml written");
		System.out.println(df.format(new Date()) + "sample citygml4j application successfully finished");
	}

	
	public void createDoor(BoundarySurfaceProperty bsp) throws DimensionMismatchException {
		System.out.println("c");
		AbstractBoundarySurface b = bsp.getBoundarySurface();
		if (b instanceof WallSurface) {
			System.out.println("IS wall surf");
			GMLGeometryFactory geom = new GMLGeometryFactory();
			WallSurface ws = (WallSurface) b;
			Door door = new Door();
			OpeningProperty openingProperty = new OpeningProperty();			
			openingProperty.setObject(door);			
			//Polygon doorPoly= geom.createLinearPolygon(new double[] {-3.5,0.1,0, -6.5,0.1,0, -6.5,0.1,2.3, -3.5,0.1,2.3, -3.5,0.1,0}, 3);
			//Polygon doorPoly2 = geom.createLinearPolygon(new double[] {-3.5,-0.1,0, -6.5,-0.1,0, -6.5,-0.1,2.3, -3.5,-0.1,2.3, -3.5,-0.1,0}, 3);
			//List l = new ArrayList();
			//l.add(doorPoly);
			//l.add(doorPoly2);
			//door.setLod4MultiSurface(new MultiSurfaceProperty(new MultiSurface(l)));
			ws.addOpening(openingProperty);
		}				
	}
	
	
	public void createWindow(BoundarySurfaceProperty bsp) throws DimensionMismatchException {
		System.out.println("c");
		AbstractBoundarySurface b = bsp.getBoundarySurface();
		if (b instanceof WallSurface) {
			System.out.println("IS wall surf");
			
			GMLGeometryFactory geom = new GMLGeometryFactory();
			
			WallSurface ws = (WallSurface) b;
			
			Window window3 = new Window();
			
			OpeningProperty openingProperty = new OpeningProperty();			
			openingProperty.setObject(window3);			
			
			
			
			
			
			ws.addOpening(openingProperty);
		}				
	}
	
	
	private BoundarySurfaceProperty createBoundarySurface(CityGMLClass type, Polygon geometry) {
		AbstractBoundarySurface boundarySurface = null;

		switch (type) {
		case BUILDING_WALL_SURFACE:
			boundarySurface = new WallSurface();
			break;
		case BUILDING_ROOF_SURFACE:
			boundarySurface = new RoofSurface();
			break;
		case BUILDING_GROUND_SURFACE:
			boundarySurface = new GroundSurface();
			break;
			
		case BUILDING_FLOOR_SURFACE:
			boundarySurface = new FloorSurface();
			break;
			
		default:
			break;
		}

		if (boundarySurface != null) {
			boundarySurface.setLod4MultiSurface(new MultiSurfaceProperty(new MultiSurface(geometry)));
			return new BoundarySurfaceProperty(boundarySurface);
		}

		return null;
	}
	
		
	private static List<Foot> readFootsFromCSV(String fileName) {
		  List<Foot> foots = new ArrayList<>();
		  Path pathToFile = Paths.get(fileName);
		  // create an instance of BufferedReader
		  // using try with resource, Java 7 feature to close resources 
		  try (BufferedReader br = Files.newBufferedReader(pathToFile, 

		  StandardCharsets.US_ASCII)) {
			  // read the first line from the text file
			  String line = br.readLine();
			  // loop until all lines are read 
			   while (line != null) { 
				  // use string.split to load a string array with the values from 
				  // each line of 
				  // the file, using a comma as the delimiter				 
				  if (line.length()==0){
				    	line = br.readLine(); 
				  }else {
				        String[] attributes = line.split(","); 
				        Foot foot = createFoot(attributes); 
				        // adding book into ArrayList 
				        foots.add(foot); 
				        //read next line before looping 
				        //if end of file reached, 
				        line = br.readLine(); 
				   }
				 
			    }
		    } catch (IOException ioe) { 
		          ioe.printStackTrace();
		    }
		      return foots; 
		  
		  } 
	private static Foot createFoot(String[] metadata) { 
		double ref = Double.parseDouble(metadata[0]);
		double lat = Double.parseDouble(metadata[1]);
		double lon = Double.parseDouble(metadata[2]); 
		// create and return foot of this meta data 
		return new Foot(ref,lat, lon);
		} 	

}
