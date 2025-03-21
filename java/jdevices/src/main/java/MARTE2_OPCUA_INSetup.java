/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author mdsplus
 */
public class MARTE2_OPCUA_INSetup extends DeviceSetup {

    /**
     * Creates new form MARTE2_OPCUA_INSetup
     */
    public MARTE2_OPCUA_INSetup() {
        initComponents();
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        deviceButtons1 = new DeviceButtons();
        jPanel1 = new javax.swing.JPanel();
        jPanel2 = new javax.swing.JPanel();
        deviceField1 = new DeviceField();
        deviceField2 = new DeviceField();
        deviceField6 = new DeviceField();
        jPanel3 = new javax.swing.JPanel();
        deviceField3 = new DeviceField();
        deviceField4 = new DeviceField();
        deviceField5 = new DeviceField();
        jScrollPane1 = new javax.swing.JScrollPane();
        deviceOutputs1 = new DeviceOutputs();

        setDeviceProvider("localhost:8100");
        setDeviceTitle("MARTE2 OPCUA In");
        setDeviceType("MARTE2_OPCUA_IN");
        setHeight(300);
        setWidth(800);
        getContentPane().add(deviceButtons1, java.awt.BorderLayout.PAGE_END);

        jPanel1.setLayout(new java.awt.GridLayout(2, 1));

        deviceField1.setIdentifier("");
        deviceField1.setLabelString("Address");
        deviceField1.setNumCols(25);
        deviceField1.setOffsetNid(7);
        deviceField1.setTextOnly(true);
        jPanel2.add(deviceField1);

        deviceField2.setIdentifier("");
        deviceField2.setLabelString("CPU Mask");
        deviceField2.setNumCols(8);
        deviceField2.setOffsetNid(22);
        jPanel2.add(deviceField2);

        deviceField6.setIdentifier("");
        deviceField6.setLabelString("RootIdentifierType: ");
        deviceField6.setOffsetNid(37);
        deviceField6.setTextOnly(true);
        jPanel2.add(deviceField6);

        jPanel1.add(jPanel2);

        deviceField3.setIdentifier("");
        deviceField3.setLabelString("Traverse");
        deviceField3.setNumCols(4);
        deviceField3.setOffsetNid(28);
        jPanel3.add(deviceField3);

        deviceField4.setIdentifier("");
        deviceField4.setLabelString("RootNameSpaceIndex:");
        deviceField4.setNumCols(4);
        deviceField4.setOffsetNid(31);
        jPanel3.add(deviceField4);

        deviceField5.setIdentifier("");
        deviceField5.setLabelString("RootIdentifierValue:");
        deviceField5.setNumCols(15);
        deviceField5.setOffsetNid(34);
        deviceField5.setTextOnly(true);
        jPanel3.add(deviceField5);

        jPanel1.add(jPanel3);

        getContentPane().add(jPanel1, java.awt.BorderLayout.PAGE_START);

        deviceOutputs1.setOffsetNid(26);
        jScrollPane1.setViewportView(deviceOutputs1);

        getContentPane().add(jScrollPane1, java.awt.BorderLayout.CENTER);
    }// </editor-fold>//GEN-END:initComponents


    // Variables declaration - do not modify//GEN-BEGIN:variables
    private DeviceButtons deviceButtons1;
    private DeviceField deviceField1;
    private DeviceField deviceField2;
    private DeviceField deviceField3;
    private DeviceField deviceField4;
    private DeviceField deviceField5;
    private DeviceField deviceField6;
    private DeviceOutputs deviceOutputs1;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JPanel jPanel3;
    private javax.swing.JScrollPane jScrollPane1;
    // End of variables declaration//GEN-END:variables
}
