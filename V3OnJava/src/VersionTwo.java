import java.util.ArrayList;
import java.util.Scanner;
import java.util.StringTokenizer;

public class VersionTwo {
    private static String[] keys;
    private static double[] average;
    public static void main(String[] args) {
        Scanner sc=new Scanner(System.in);
        String input ="";
        while(true){
            String temp=sc.nextLine();
            if(temp==null || temp.isBlank()) break;
            input+=temp+"\r";
        }
        //System.out.println(turnLinesIntoStringArray(input));
        ArrayList<String>allInputLines=turnLinesIntoStringArray(input);
        fillKeyArray(allInputLines);
        fillAverageArray(allInputLines);
        sortArraysByMergeSort(average, keys, 0, average.length - 1);
        printArrays();

    }

    private static void printArrays() {
        for(int i=0;i< keys.length;i++){
            System.out.println(keys[i]+" "+average[i]);
        }
    }

    private static void sortArraysByMergeSort(double[] arr, String[] keys, int left, int right) {
        if (left < right) {
            int mid = (left + right) / 2;
            sortArraysByMergeSort(arr, keys, left, mid);
            sortArraysByMergeSort(arr, keys, mid + 1, right);
            merge(arr, keys, left, mid, right);
        }
    }

    private static void merge(double[] arr, String[] keys, int left, int mid, int right) {
        int n1 = mid - left + 1;
        int n2 = right - mid;

        double[] L = new double[n1];
        double[] R = new double[n2];
        String[] LKeys = new String[n1];
        String[] RKeys = new String[n2];

        for (int i = 0; i < n1; ++i) {
            L[i] = arr[left + i];
            LKeys[i] = keys[left + i];
        }
        for (int j = 0; j < n2; ++j) {
            R[j] = arr[mid + 1 + j];
            RKeys[j] = keys[mid + 1 + j];
        }

        int i = 0, j = 0;
        int k = left;
        while (i < n1 && j < n2) {
            if (L[i] <= R[j]) {
                arr[k] = L[i];
                keys[k] = LKeys[i];
                i++;
            } else {
                arr[k] = R[j];
                keys[k] = RKeys[j];
                j++;
            }
            k++;
        }

        while (i < n1) {
            arr[k] = L[i];
            keys[k] = LKeys[i];
            i++;
            k++;
        }

        while (j < n2) {
            arr[k] = R[j];
            keys[k] = RKeys[j];
            j++;
            k++;
        }
    }


    private static void fillAverageArray(ArrayList<String> allInputLines) {
        ArrayList <Double> averageList=new ArrayList<>();

        for(String key:keys){
            double allValues=0;
            double i=0;
            for(String x:allInputLines){
                StringTokenizer tk=new StringTokenizer(x);
                String keyTest=tk.nextToken();
                if(keyTest.equals(key)){
                    allValues+=Integer.parseInt(tk.nextToken());
                    i++;
                }
            }
            averageList.add(allValues/i);
        }
        average=new double[averageList.size()];
        //full averages array
        for(int i=0;i< averageList.size(); i++){
            average[i]=averageList.get(i);
        }
    }

    private static void fillKeyArray(ArrayList<String> lines) {
        ArrayList <String> keysList=new ArrayList<>();
        for(String x:lines){
            StringTokenizer tk=new StringTokenizer(x);
            String key=tk.nextToken();
            //check if keys contains key
            boolean isContain=false;
            for(String y:keysList){
                StringTokenizer tk1=new StringTokenizer(y);
                String key1=tk1.nextToken();
                if(key.equals(key1)) isContain=true;
            }

            if(isContain==false){
                keysList.add(key);
            }
        }
        keys=new String[keysList.size()];
        //full keys array
        for(int i=0;i< keysList.size(); i++){
            keys[i]=keysList.get(i);
        }

    }

    private static ArrayList<String> turnLinesIntoStringArray(String input){
        ArrayList <String> lines =new ArrayList<>();
        String temp="";
//        // fist variant
//        for(int i=0; i<input.length();i++){
//            if((i+8<=input.length())){
//            int test=Integer.parseInt(""+input.charAt(i)+input.charAt(i+1)+input.charAt(i+2)+input.charAt(i+3));
//            int testNext= Integer.parseInt(""+input.charAt(i+4)+input.charAt(i+5)+input.charAt(i+6)+input.charAt(i+7));
//            if(test==0x0D &&  testNext==0x0A
//            ){
//                lines.add(temp);
//                i+=7;
//            }
//            else{
//                if(test==0x0D || test==0x0A
//                ){
//                    lines.add(temp);
//                    i+=3;
//                }
//                else{
//                    temp+=input.charAt(i);
//                if((i+1)==input.length()){
//                        lines.add(temp);
//                    }
//                }
//            }}
//            else{
//                if((i+4)<=input.length()){
//                    int test=Integer.parseInt(""+input.charAt(i)+input.charAt(i+1)+input.charAt(i+2)+input.charAt(i+3));
//                        if(test==0x0D || test==0x0A
//                        ){
//                            lines.add(temp);
//                            i+=3;
//                        }
//                        else{
//                            temp+=input.charAt(i);
//                             if((i+1)==input.length()){
//                                lines.add(temp);
//                            }
//                        }
//                }
//                else{
//                    temp+=input.charAt(i);
//                    if((i+1)==input.length()){
//                        lines.add(temp);
//                    }
//                }
//            }
//        }
//        // second variant
//        for(int i=0; i<input.length();i++){
//            String test=""+input.charAt(i);
//            if(i+1<input.length()){
//                String testNext=""+input.charAt(i+1);
//                if (test.equals("\r") && testNext.equals("\n")) {
//                    lines.add(temp);
//                    i++;
//                    continue;
//                }
//            }
//            if (test.equals("\r") || test.equals("\n")) {
//                    lines.add(temp);
//
//            }
//            else{
//                temp+=test;
//                if((i+1)==input.length()){
//                        lines.add(temp);
//                    }
//            }
//        }
//
//      third variant

        StringTokenizer tk1=new StringTokenizer(input, "\r");
        while(tk1.hasMoreTokens()){
            String s= tk1.nextToken();
            if(!s.isBlank())lines.add(s);
        }


        return lines;
    }


}